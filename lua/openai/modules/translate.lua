--[[----------------------------------------------------------------------------
                                translate Module
----------------------------------------------------------------------------]]--

OpenAI.Config.Translate = {}
OpenAI.Config.Translate.enabled = CreateConVar("openai_translate_enabled", 0, {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable the translation module", 0, 1)

OpenAI.Config.Translate.Model = CreateConVar("openai_translate_model", "gpt-3.5-turbo", {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Set the model for the translation module")
OpenAI.Config.Translate.Prefix = CreateConVar("openai_translate_model", ".", {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Set the prefix of the translation module")
OpenAI.Config.Translate.Temperature = CreateConVar("openai_translate_temperature", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Set the temperature for the translation module")
OpenAI.Config.Translate.MaxTokens = CreateConVar("openai_translate_maxtokens", 24, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Set the maximun amount of tokens for the translation module")

if CLIENT then
    CreateClientConVar("openai_translate_from", "spanish", true, true, "Request a translate from a language")
    CreateClientConVar("openai_translate_to", "english", true, true, "Request a translate to a language")
    return
end

--[[------------------------
      Local Definitions
------------------------]]--


--[[------------------------
        Main Scripts
------------------------]]--

local namehook = "OpenAI.OnTranslateReceive"
function OpenAI.TranslateFetch(ply, msg)

    if not OpenAI.Config.Translate.enabled:GetBool() then return end
    if hook.Run("OpenAI.translatePlyCanUse", ply) == false then return end

    local content = string.format("Translate this %s text into %s text\n\n%s", ply:GetInfo("openai_translate_from"), ply:GetInfo("openai_translate_to"), msg)
    local request = OpenAI.Request()
    request:SetType("chat")
    request:AddBody("model", OpenAI.Config.Translate.Model:GetString())
    request:AddBody("messages", {
      { role = "user", content = content}
    })
    request:AddBody("temperature", OpenAI.Config.Translate.Temperature:GetFloat())
    request:AddBody("max_tokens", OpenAI.Config.Translate.MaxTokens:GetFloat())
    request:AddBody("user", ply)
    request:SetSuccess(function(code, body)
        OpenAI.HandleCode(code)

        local json = util.JSONToTable( string.Trim( body ) )

        if code == 200 then

            local response = string.Trim(json["choices"][1]["message"]["content"])
            response = string.gsub(response, [[^[%s",%.]*(.-)[%s",%.]*$]], "%1")

            OpenAI.SendMessage(ply, msg, response, namehook, "Translate")
            hook.Call(namehook, nil, ply, msg, response)

        elseif code >= 400 then

            mError = json["error"]["message"]
            MsgC(COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] ", COLOR_RED, mError, "\n")

            if GetConVar("openai_displayerrorcl"):GetBool() then
                OpenAI.SendError(ply, mError)
            end

        end
    end)

    request:SendRequest()
end


--[[------------------------
      Commands Scripts
------------------------]]--

hook.Add("OpenAI.translatePlyCanUse", "OpenAI.translatePlyCanUse", function(ply)
    
    local admin = GetConVar("openai_admin"):GetInt()
    local canUse = false

    if admin == 1 then
        canUse = true
    elseif admin == 2 then
        canUse = ply:IsAdmin()
    elseif admin == 3 then
        canUse = ply:IsSuperAdmin()
    elseif admin == 4 then
        if ULib then
            canUse = ULib.ucl.query(ply, "openai translate")
        end
    end

    return canUse
end)

hook.Add("PlayerSay", "OpenAI.translate", function(ply, text)

    local prefix, prompt = text:sub(1,1), text:sub(1)

    if prefix == OpenAI.Config.Translate.Prefix:GetString() then
        if prompt == nil or #prompt < 1 then return end
        OpenAI.TranslateFetch(ply, prompt)

        return ""
    end

end)
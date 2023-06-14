--[[----------------------------------------------------------------------------
                                translate Module
----------------------------------------------------------------------------]]--

OpenAI.Config.Translate = {}
OpenAI.Config.Translate.enabled = CreateConVar("openai_translate_enabled", 0, {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable the translation module", 0, 1)

if CLIENT then
    CreateConVar("openai_translate_from", "spanish", {FCVAR_ARCHIVE, FCVAR_USERINFO}, "Request a translate from a language")
    CreateConVar("openai_translate_to", "english", {FCVAR_ARCHIVE, FCVAR_USERINFO}, "Request a translate to a language")
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
    local openai = OpenAI.Request():SetType("chat")
    :AddBody("model", OpenAI.GetConfig("translator_model"))
    :AddBody("messages", {
      { role = "user", content = content}  
    })
    :AddBody("temperature", OpenAI.GetConfig("translator_temperature"))
    :AddBody("max_tokens", OpenAI.GetConfig("translator_max_tokens"))
    :AddBody("user", ply)
    :SetSuccess(function(code, body)
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

    openai:SendRequest()
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

    if prefix == OpenAI.GetConfig("translator_cmd") then
        if prompt == nil or #prompt < 1 then return end
        OpenAI.TranslateFetch(ply, prompt)

        return ""
    end

end)
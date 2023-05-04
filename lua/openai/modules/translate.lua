--[[----------------------------------------------------------------------------
                                translate Module
----------------------------------------------------------------------------]]--

local enabled = CreateConVar("openai_translate_enabled", 0, {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable the translation module", 0, 1)

if SERVER then
    util.AddNetworkString("openai.translateSVtoCL")
end

if CLIENT then
    CreateConVar("openai_translate_from", "spanish", {FCVAR_ARCHIVE, FCVAR_USERINFO}, "Request a translate from a language")
    CreateConVar("openai_translate_to", "english", {FCVAR_ARCHIVE, FCVAR_USERINFO}, "Request a translate to a language")

    net.Receive("openai.translateSVtoCL", function()
        local ply = net.ReadEntity()
        local prompt = net.ReadString()
        local response = net.ReadString()

        OpenAI.ChatPrint("[Translate] ", COLOR_WHITE, IsValid(ply) and ply:Nick() or "Disconnected", ": ", COLOR_CLIENT, response)

        hook.Call("OpenAI.onTranslateReceive", nil, ply, prompt, response)
    end)

    return
end

--[[------------------------
      Local Definitions
------------------------]]--


--[[------------------------
        Main Scripts
------------------------]]--

function OpenAI.TranslateFetch(ply, msg)
    if not enabled:GetBool() then return end

    local cfg = OpenAI.FileRead()

    local canUse = hook.Run("OpenAI.translatePlyCanUse", ply)
    if canUse == false then return end

    local lang_from = ply:GetInfo("openai_translate_from")
    local lang_to = ply:GetInfo("openai_translate_to")

    local content = string.format("Translate this %s text into %s text\n\n%s", lang_from, lang_to, msg)

    local openai = OpenAI.Request()
    openai:SetType("chat")
    openai:AddBody("model", OpenAI.GetConfig("translator_model"))
    openai:AddBody("messages", {
      { role = "user", content = content}  
    })
    openai:AddBody("temperature", OpenAI.GetConfig("translator_temperature"))
    openai:AddBody("max_tokens", OpenAI.GetConfig("translator_max_tokens"))
    openai:AddBody("user", ply)

    openai:SetSuccess(function(code, body)
        OpenAI.HandleCode(code)

        local json = util.JSONToTable( string.Trim( body ) )

        if code == 200 then
            local response = string.Trim(json["choices"][1]["message"]["content"])

            response = string.gsub(response, [[^[%s",%.]*(.-)[%s",%.]*$]], "%1")

            net.Start("openai.translateSVtoCL")
                net.WriteEntity(ply)
                net.WriteString(msg)
                net.WriteString(response)
            net.Broadcast()

            hook.Call("OpenAI.translateFetch", nil, ply, msg, response)
        elseif code >= 400 then
            mError = json["error"]["message"]
            MsgC(COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] ", COLOR_RED, mError, "\n")
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
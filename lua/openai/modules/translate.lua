--[[----------------------------------------------------------------------------
                                translate Module
----------------------------------------------------------------------------]]--

CreateConVar("openai_translate_enabled", 0, FCVAR_NOTIFY, FCVAR_ARCHIVE, "Enable the translation module", 0, 1)

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

        OpenAI.chatPrint("[Translate] ", COLOR_WHITE, IsValid(ply) and ply:Nick() or "Disconnected", ": ", COLOR_CLIENT, response)

        hook.Call("OpenAI.onTranslateReceive", nil, ply, prompt, response)
    end)

    return
end

--[[------------------------
      Local Definitions
------------------------]]--

local function GetPath()
    return string.GetFileFromFilename( debug.getinfo(1, "S")["short_src"] )
end


--[[------------------------
        Main Scripts
------------------------]]--

function OpenAI.translateFetch(ply, msg)
    local cfg = OpenAI.FileRead()

    local canUse = hook.Run("OpenAI.translatePlyCanUse", ply)
    if canUse == false then return end

    local lang_from = ply:GetInfo("openai_translate_from")
    local lang_to = ply:GetInfo("openai_translate_to")

    local content = string.format("Generate a translation from %s to %s\n%s: %s\n%s:", lang_from, lang_to, lang_from, msg, lang_to)

    local body = {
        model       = cfg["translator_model"],
        messages    = {
            { role = "user", content = content }
        },
        temperature = cfg["translator_temperature"],
        max_tokens  = cfg["translator_max_tokens"],
        user        = OpenAI.replaceSteamID( cfg["translator_user"], ply ),
    }

    local openai = OpenAI.Request()
    openai:SetType("chat")
    openai:SetBody(body)
    openai:SetSuccess(function(code, body)
        OpenAI.HandleCode(code, GetPath())

        local json = util.JSONToTable( string.Trim( body ) )

        if code == 200 then
            local response = json["choices"][1]["message"]["content"]

            net.Start("openai.translateSVtoCL")
                net.WriteEntity(ply)
                net.WriteString(msg)
                net.WriteString(response)
            net.Broadcast()

            hook.Call("OpenAI.translateFetch", nil, ply, msg, response)
        end
    end)
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
            canUse = ULib.ucl.query(ply, "OpenAI.chat")
        end
    end

    return canUse
end)

hook.Add("PlayerSay", "OpenAI.translate", function(ply, text)

    local prefix, prompt = text:sub(1,1)

    if prefix == nil or cmd ~= cfg["translator_cmd"] then return end
    if prompt == nil or #prompt < 1 then return end

    OpenAI.translateFetch(ply, prompt)

    return ""
end)
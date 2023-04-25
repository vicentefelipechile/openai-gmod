--[[----------------------------------------------------------------------------
                                translate Module
----------------------------------------------------------------------------]]--

local function GetPath()
    return string.GetFileFromFilename( debug.getinfo(1, "S")["short_src"] )
end

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


local cfg = OpenAI.FileRead()
local API = cfg["openai"] or false

local header = API and {
    ["Authorization"] = "Bearer " .. API,
}


--[[------------------------
        Main Scripts
------------------------]]--

function OpenAI.translateFetch(ply, msg)
    if not API then return end

    local canUse = hook.Run("OpenAI.translatePlyCanUse", ply)
    if canUse == false then return end

    local lang_from = ply:GetInfo("openai_translate_from")
    local lang_to = ply:GetInfo("openai_translate_to")

    local content = string.format("Generate a translation from %s to %s\n%s: %s\n%s:", lang_from, lang_to, lang_from, msg, lang_to)

    local body = util.TableToJSON({
        model       = cfg["translator_model"],
        messages    = {
            { role = "user", content = content }
        },
        temperature = tonumber(cfg["translator_temperature"]),
        max_tokens  = tonumber(cfg["translator_max_tokens"]),
        user        = OpenAI.replaceSteamID( cfg["translator_user"], ply ),
    })

    local jsonBody = OpenAI.IntToJson("max_tokens", body )

    OpenAI.HTTP("chat", jsonBody, header, function(code, body)
        local fCode = OpenAI.HTTPcode[code] or function() MsgC(code) end
        fCode(GetPath())

        local json = util.JSONToTable( string.Trim( body ) )

        if code == 200 then
            local response = json["choices"][1]["message"]["content"]

            net.Start("openai.translateSVtoCL")
                net.WriteEntity(ply)
                net.WriteString(msg)
                net.WriteString(response)
            net.Broadcast()

            hook.Call("OpenAI.translateFetch", nil, ply, msg, response)
        elseif code == 400 then
            mError = json["error"]["message"]
            MsgC(COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] ", COLOR_RED, mError, "\n")

            if GetConVar("openai_displayerrorcl"):GetBool() then
                net.Start("OpenAI.errorToCL")
                    net.WriteString(json["error"]["message"])
                net.Send(ply)
            end

        end

    end,
    function(err)
        MsgC(COLOR_RED, err)
    end)
end


concommand.Add("openai_translate_reloadconfig", function()
    cfg = OpenAI.FileRead()
end)


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
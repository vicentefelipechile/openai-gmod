--[[----------------------------------------------------------------------------
                                Chat Module
----------------------------------------------------------------------------]]--

local noshow = CreateConVar("openai_chat_noshow", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Should show the command in the chat?", 0, 1)

if SERVER then
    util.AddNetworkString("openai.chatSVtoCL")
end

if CLIENT then
    net.Receive("openai.chatSVtoCL", function()
        local ply = net.ReadEntity()
        local prompt = net.ReadString()
        local response = net.ReadString()

        OpenAI.chatPrint("[Chat] ", COLOR_WHITE, IsValid(ply) and ply:Nick() or "Disconnected", ": ", COLOR_CLIENT, prompt)
        OpenAI.chatPrint("[Chat] ", COLOR_WHITE, "OpenAI: ", response)

        hook.Call("OpenAI.onChatReceive", nil, ply, prompt, response)
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

local c_error = COLOR_RED
local c_normal = COLOR_SERVER


do
    if not file.Exists("openai/chat", "DATA") then
        file.CreateDir("openai/chat")
    end
end


--[[------------------------
        Main Scripts
------------------------]]--

function OpenAI.GetPlayerChat(ply)
    local messages

    if not file.Exists("openai/chat/log_" .. ply:SteamID64() .. ".json", "DATA") then
        file.Write("openai/chat/log_" .. ply:SteamID64() .. ".json", "")
    end
end

function OpenAI.chatFetch(ply, msg)
    if not API then return end

    local canUse = hook.Run("OpenAI.chatPlyCanUse", ply)
    if canUse == false then return end

    local body = {
        model       = cfg["chat_model"],
        messages    = {{
            role = "user",
            content = msg
        }},
        temperature = tonumber(cfg["chat_temperature"]),
        max_tokens  = tonumber(cfg["chat_max_tokens"]),
        user        = OpenAI.replaceSteamID( cfg["chat_user"], ply ),
    }

    local jsonBody = OpenAI.IntToJson("max_tokens", util.TableToJSON(body) )

    OpenAI.HTTP("chat", jsonBody, header, function(code, body)
        local fCode = OpenAI.HTTPcode[code] or function() MsgC(code) end
        fCode()

        local json = util.JSONToTable( string.Trim( body ) )

        if code == 200 then
            local response = json["choices"][1]["message"]["content"]

            net.Start("openai.chatSVtoCL")
                net.WriteEntity(ply)
                net.WriteString(msg)
                net.WriteString(response)
            net.Broadcast()

            hook.Call("OpenAI.chatFetch", nil, ply, msg, response)
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


concommand.Add("openai_chat_reloadconfig", function()
    cfg = OpenAI.FileRead()
end)


--[[------------------------
      Commands Scripts
------------------------]]--

hook.Add("OpenAI.chatPlyCanUse", "OpenAI.chatPlyCanUse", function(ply)
    
    local admin = GetConVar("openai_admin"):GetInt()
    local canUse = false

    if admin == 0 then
        if ULib then
            canUse = ULib.ucl.query(ply, "OpenAI.chat")
        else
            canUse = true
        end
    elseif admin == 1 then
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

hook.Add("PlayerSay", "OpenAI.chat", function(ply, text)

    local cmd, prompt = OpenAI.handleCommands(text)

    if cmd == nil or cmd ~= "chat" then return end
    if prompt == nil or #prompt < 1 then return end

    OpenAI.chatFetch(ply, prompt)

    return noshow:GetBool() and "" or text
end)
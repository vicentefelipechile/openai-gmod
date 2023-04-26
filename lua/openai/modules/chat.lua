--[[----------------------------------------------------------------------------
                                Chat Module
----------------------------------------------------------------------------]]--

local noshow = CreateConVar("openai_chat_noshow", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Should show the command in the chat?", 0, 1)
local alwaysreset = CreateConVar("openai_chat_alwaysreset", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Always reset the chat?")

local function GetPath()
    return string.GetFileFromFilename( debug.getinfo(1, "S")["short_src"] )
end

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

function OpenAI.chatFetch(ply, msg)

    local canUse = hook.Run("OpenAI.chatPlyCanUse", ply)
    if canUse == false then return end

    local cfg = OpenAI.FileRead()

    local body = {
        model       = cfg["chat_model"],
        messages    = {
            { role = "user", content = msg }
        },
        temperature = cfg["chat_temperature"],
        max_tokens  = cfg["chat_max_tokens"],
        user        = OpenAI.replaceSteamID( cfg["chat_user"], ply ),
    }

    local openai = OpenAI.Request()
    openai:SetType("chat")
    openai:SetBody(body)
    openai:SetSuccess(function(code, body)
        OpenAI.HandleCode(code, GetPath())

        local json = util.JSONToTable( string.Trim( body ) )

        if code == 200 then
            local response = json["choices"][1]["message"]["content"]

            net.Start("openai.chatSVtoCL")
                net.WriteEntity(ply)
                net.WriteString(msg)
                net.WriteString(response)
            net.Broadcast()

            hook.Call("OpenAI.chatFetch", nil, ply, msg, response)
        elseif code >= 400 then
            mError = json["error"]["message"]
            MsgC(COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] ", COLOR_RED, mError, "\n")

            if GetConVar("openai_displayerrorcl"):GetBool() then
                net.Start("OpenAI.errorToCL")
                    net.WriteString(json["error"]["message"])
                net.Send(ply)
            end
        end
    end)

    openai:SendRequest()
end



--[[------------------------
      Commands Scripts
------------------------]]--

hook.Add("OpenAI.chatPlyCanUse", "OpenAI.chatPlyCanUse", function(ply)
    
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

hook.Add("PlayerSay", "OpenAI.chat", function(ply, text)

    local cmd, prompt = OpenAI.handleCommands(text)

    if cmd == nil or cmd ~= "chat" then return end
    if prompt == nil or #prompt < 1 then return end

    OpenAI.chatFetch(ply, prompt)

    return noshow:GetBool() and "" or text
end)
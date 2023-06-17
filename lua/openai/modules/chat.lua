--[[----------------------------------------------------------------------------
                                Chat Module
----------------------------------------------------------------------------]]--

OpenAI.Config.Chat = {}
OpenAI.Config.Chat.NoShow = CreateConVar("openai_chat_noshow", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Should show the command in the chat?", 0, 1)
OpenAI.Config.Chat.AlwaysReset = CreateConVar("openai_chat_alwaysreset", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Always reset the chat?")

OpenAI.Config.Chat.Model = CreateConVar("openai_chat_model", "gpt-3.5-turbo", {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Set the model for the Chat module")
OpenAI.Config.Chat.Temperature = CreateConVar("openai_chat_temperature", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Set the temperature for the Chat module")
OpenAI.Config.Chat.MaxTokens = CreateConVar("openai_chat_maxtokens", 24, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Set the maximun amount of tokens for the Chat module")

if CLIENT then return end

--[[------------------------
      Local Definitions
------------------------]]--

local namehook = "OpenAI.OnChatReceive"
OpenAI.ChatHistory = OpenAI.ChatHistory or {}

--[[------------------------
        Main Scripts
------------------------]]--

function OpenAI.ChatFetch(ply, msg)

    local canUse = hook.Run("OpenAI.chatPlyCanUse", ply)
    if canUse == false then return end

    if OpenAI.Config.Chat.AlwaysReset:GetBool() then
        OpenAI.ChatHistory[ply:SteamID()] = nil
    end

    if not OpenAI.ChatHistory[ply:SteamID()] then
        --[[
        Some cringe message
        OpenAI.ChatHistory[ply:SteamID()] = {
            { role = "user", content = "You are a cute anime girl" },
            { role = "assistant", content = "OwO" }
        }

        OpenAI.ChatHistory[ply:SteamID()][0] = {
            { role = "system", content = "You are a cute anime girl" }
        }
        --]]

        OpenAI.ChatHistory[ply:SteamID()] = {}
    end

    table.insert(OpenAI.ChatHistory[ply:SteamID()], { role = "user", content = msg })

    local request = OpenAI.Request()
    request:SetType("chat")
    request:AddBody("model", OpenAI.Config.Chat.Model:GetString())
    request:AddBody("messages", OpenAI.ChatHistory[ply:SteamID()])
    request:AddBody("temperature", OpenAI.Config.Chat.Temperature:GetFloat())
    request:AddBody("max_tokens", OpenAI.Config.Chat.MaxTokens:GetInt())
    request:AddBody("user", ply)
    request:SetSuccess(function(code, body)
        OpenAI.HandleCode(code)

        local json = util.JSONToTable( string.Trim( body ) )

        if code == 200 then

            local response = json["choices"][1]["message"]["content"]
            table.insert( OpenAI.ChatHistory[ply:SteamID()], { role = "assistant", content = response } )

            OpenAI.SendMessage(ply, msg, response, namehook, "Chat")
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
            canUse = ULib.ucl.query(ply, "openai chat")
        end
    end

    return canUse
end)

hook.Add("PlayerSay", "OpenAI.chat", function(ply, text)

    if string.lower( text ) == "!chat reset" then
        OpenAI.ChatHistory[ply:SteamID()] = nil
        return OpenAI.Config.Chat.NoShow:GetBool() and "" or text
    end

    local cmd, prompt = OpenAI.HandleCommands(text)

    if cmd == nil or cmd ~= "chat" then return end
    if prompt == nil or #prompt < 1 then return end

    OpenAI.ChatFetch(ply, prompt)

    return OpenAI.Config.Chat.NoShow:GetBool() and "" or text
end)
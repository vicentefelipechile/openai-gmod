--[[----------------------------------------------------------------------------
                                Chat Module
----------------------------------------------------------------------------]]--

if SERVER then
    util.AddNetworkString("openai.chatCLtoSV")
    util.AddNetworkString("openai.chatSVtoCL")
end

if CLIENT then
    net.Receive("openai.chatSVtoCL", function()
        local ply = net.ReadEntity()
        local prompt = net.ReadString()
        local response = net.ReadString()

        OpenAI.chatPrint("[Chat] ", COLOR_WHITE, ply:Nick(), COLOR_CLIENT, " :", prompt)
        OpenAI.chatPrint("[Chat] ", COLOR_WHITE, "OpenAI :", response)
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

local function replaceSteamID(text, ply)
    if string.find(text, "%[steamid%]") then
    text = string.gsub(text, "%[steamid%]", ply:SteamID())
    end

    if string.find(text, "%[steamid64%]") then
    text = string.gsub(text, "%[steamid64%]", ply:SteamID64())
    end

    return text
end

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

    local body = {
        model       = cfg["chat_model"],
        messages    = string.gsub(cfg["message"], "%[first_message%]", msg),
        temperature = cfg["chat_temperature"],
        max_tokens  = cfg["chat_max_tokens"],
        user        = replaceSteamID( cfg["chat_user"], ply ),
    }

    local jsonBody = OpenAI.JSONEncode(body)

    OpenAI.HTTP("chat", jsonBody, header, function(code, body)
        local fCode = OpenAI.HTTPcode[code] or function() OpenAI.print(code) end
        fCode()

        if code == 200 then
            json = util.JSONToTable( string.Trim( body ) )

            local response = json["choices"]["message"]["content"]

            net.Start("openai.chatSVtoCL")
                net.WriteEntity(ply)
                net.WriteString(msg)
                net.WriteString(response)
            net.Broadcast()
        end
    end,
    function(err)
        OpenAI.print(c_error, err)
    end)
end


function OpenAI.handleChat(ply, str)

end


do
    if ULib then
        
    end
end
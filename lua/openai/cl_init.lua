--[[----------------------------------------------------------------------------
                                Client-Side OpenAI
----------------------------------------------------------------------------]]--


function OpenAI.ChatPrint(...)
    local color = COLOR_SERVER

    chat.AddText(color, unpack({...}))
end

net.Receive("OpenAI.errorToCL", function()
    if not GetConVar("openai_displayerrorcl"):GetBool() then return end
    local msg = net.ReadString()

    OpenAI.ChatPrint("[OpenAI] ", COLOR_RED, "Error: ", COLOR_WHITE, msg, "\n")
end)

net.Receive("OpenAI.SVtoCL", function()
    local ply = net.ReadEntity()
    local prompt = net.ReadString()
    local response = net.ReadString()
    local namehook = net.ReadString()
    local prefix = net.ReadString()

    OpenAI.ChatPrint("[", prefix, "] ", COLOR_WHITE, IsValid(ply) and ply:Nick() or "Disconnected", ": ", COLOR_CLIENT, prompt)
    OpenAI.ChatPrint("[", prefix, "] ", COLOR_WHITE, "OpenAI: ", response)

    hook.Call(namehook, nil, ply, prompt, response)
end)
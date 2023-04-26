--[[----------------------------------------------------------------------------
                                Client-Side OpenAI
----------------------------------------------------------------------------]]--


function OpenAI.ChatPrint(...)
    local color = COLOR_SERVER

    chat.AddText(color, unpack({...}))
end
OpenAI.chatPrint = OpenAI.ChatPrint

net.Receive("OpenAI.errorToCL", function()
    if not GetConVar("openai_displayerrorcl"):GetBool() then return end
    local msg = net.ReadString()

    OpenAI.ChatPrint("[OpenAI] ", COLOR_RED, "Error: ", COLOR_WHITE, msg, "\n")
end)
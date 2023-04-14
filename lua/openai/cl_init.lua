--[[----------------------------------------------------------------------------
                                Client-Side OpenAI
----------------------------------------------------------------------------]]--


function OpenAI.chatPrint(...)
    local color = COLOR_SERVER

    chat.AddText(color, unpack({...}))
end

net.Receive("OpenAI.errorToCL", function()
    if not GetConVar("openai_displayerrorcl"):GetBool() then return end
    local msg = net.ReadString()

    OpenAI.chatPrint("[OpenAI] ", COLOR_RED, "Error: ", COLOR_WHITE, msg, "\n")
end)
--[[----------------------------------------------------------------------------
                                Client-Side OpenAI
----------------------------------------------------------------------------]]--


function OpenAI.chatPrint(...)
    local color = COLOR_SERVER

    chat.AddText(color, unpack({...}))
end
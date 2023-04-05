OPENAI_ULX = "OpenAI"

function ulx.openaiChat(ply, prompt)
    if message:len() >= 6 then
        return
    end

    OpenAI.chatFetch(ply, prompt)

    ulx.fancyLog(ply, "#P ask to OpenAI: #s", prompt)
end
local openaiChat = ulx.command( OPENAI_ULX, "openai chat", ulx.openaiChat )
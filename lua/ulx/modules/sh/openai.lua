--[[----------------------------------------------------------------------------
                                ULX Module
----------------------------------------------------------------------------]]--

OPENAI_ULX = "OpenAI"

--[[------------------------
        Chat Command
------------------------]]--
function ulx.openaiChat(ply, prompt)
    if prompt:len() >= 6 then
        return
    end

    OpenAI.ChatFetch(ply, prompt)

    ulx.fancyLog(ply, "#P asked to OpenAI: #s", prompt)
end
local openaiChat = ulx.command( OPENAI_ULX, "openai chat", ulx.openaiChat )
openaiChat:addParam{ type=ULib.cmds.StringArg, hint="Ask anything" }
openaiChat:defaultAccess( ULib.ACCESS_ALL )
openaiChat:help("Generate a prompt from OpenAI")


--[[------------------------
        Images Command
------------------------]]--
function ulx.openaiImage(ply, prompt)
    if prompt:len() >= 6 then
        return
    end

    OpenAI.ImageFetch(ply, prompt)

    ulx.fancyLog(ply, "#P asked to Dalle: #s", prompt)
end
local openaiImage = ulx.command( OPENAI_ULX, "openai image", ulx.openaiImage )
openaiImage:addParam{ type=ULib.cmds.StringArg, hint="Ask anything" }
openaiImage:defaultAccess( ULib.ACCESS_ALL )
openaiImage:help("Generate a image from OpenAI")


--[[------------------------
      Translate Command
------------------------]]--
function ulx.openaiTranslate(ply, prompt)
    if prompt:len() >= 6 then
        return
    end

    OpenAI.TranslateFetch(ply, prompt)

    ulx.fancyLog(ply, "#P asked to translate this: #s", prompt)
end
local openaiTranslate = ulx.command( OPENAI_ULX, "openai translate", ulx.openaiTranslate )
openaiTranslate:addParam{ type=ULib.cmds.StringArg, hint="Ask anything" }
openaiTranslate:defaultAccess( ULib.ACCESS_ALL )
openaiTranslate:help("Generate a translation from OpenAI")


--[[------------------------
      TTS Module Command
------------------------]]--
function ulx.openaiElevenlabs(ply, prompt)
    if prompt:len() >= 6 then
        return
    end

    OpenAI.ElevenlabsTTS(ply, prompt)

    ulx.fancyLog(ply, "#P asked to translate this: #s", prompt)
end
local openaiTranslate = ulx.command( OPENAI_ULX, "openai elevenlabs", ulx.openaiTranslate )
openaiTranslate:addParam{ type=ULib.cmds.StringArg, hint="Ask anything" }
openaiTranslate:defaultAccess( ULib.ACCESS_ALL )
openaiTranslate:help("Generate a translation from OpenAI")
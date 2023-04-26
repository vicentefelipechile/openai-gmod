--[[----------------------------------------------------------------------------
                                Shared OpenAI
----------------------------------------------------------------------------]]--

CreateConVar("openai_admin", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "What type of admin we should to use? (1: All-Users, 2: Only Admin, 3: Only SuperAdmin, 4: ULX)")
CreateConVar("openai_displayerrorcl", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Display error to client?", 0, 1)


--[[----------------------------
        Shared Functions
----------------------------]]--
function OpenAI.print(...)
    local color = SERVER and COLOR_SERVER or COLOR_CLIENT

    MsgC(color, unpack({...}), "\n")
end


function OpenAI.handleCommands(str)
    local command, value = str:match("^(%S+)%s+(.*)$")

    if command and command:sub(1,1) == "!" then
        command = command:sub(2)
    else
        return nil
    end

    return command, value
end
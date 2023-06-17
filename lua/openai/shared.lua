--[[----------------------------------------------------------------------------
                                Shared OpenAI
----------------------------------------------------------------------------]]--

OpenAI.Config.Admin = CreateConVar("openai_admin", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "What type of admin we should to use? (1: All-Users, 2: Only Admin, 3: Only SuperAdmin, 4: ULX)")
OpenAI.Config.DisplayErrorCL = CreateConVar("openai_displayerrorcl", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Display error to client?", 0, 1)


--[[----------------------------
        Shared Functions
----------------------------]]--
function OpenAI.Print(...)
    local color = SERVER and COLOR_SERVER or COLOR_CLIENT

    MsgC(color, unpack({...}))
    MsgC("\n")
end


function OpenAI.SetFileName(name, format, dir)
    local unixtime = os.time()
    local name = string.lower( name:gsub("[%p%c]", ""):gsub("%s+", "_") )

    if dir and not file.Exists("openai/" .. dir, "DATA") then
        file.CreateDir("openai/" .. dir)
    end
    
    if format == nil then
        format = ".txt"
    end

    if not ( format:sub(0,1) == "." ) then
        format = "." .. format
    end

    if name:len() > 32 then
        name = name:sub(1, 32)
    end

    local format = "openai/" .. ( dir == nil and "" or dir .. "/" ) .. "%d_%s" .. format
    
    return string.format(format, unixtime, name)
end


function OpenAI.HandleCommands(str)
    local command, value = str:match("^(%S+)%s+(.*)$")

    if command and command:sub(1,1) == "!" then
        command = command:sub(2)
    else
        return nil
    end

    return command, value
end
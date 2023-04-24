--[[----------------------------------------------------------------------------
                                Shared OpenAI
----------------------------------------------------------------------------]]--
OpenAI.Commands = OpenAI.Commands or {}

CreateConVar("openai_admin", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "What type of admin we should to use? (1: All-Users, 2: Only Admin, 3: Only SuperAdmin, 4: ULX)")
CreateConVar("openai_displayerrorcl", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Display error to client?", 0, 1)


--[[----------------------------
        Include Files
----------------------------]]--
if SERVER then
    AddCSLuaFile("openai/modules/enum_color.lua")
    AddCSLuaFile("openai/modules/httpcode.lua")
    include("openai/server/default.lua")
    include("openai/server/binarymodule.lua")

    AddCSLuaFile("openai/modules/chat.lua")
    AddCSLuaFile("openai/modules/dalle.lua")
    AddCSLuaFile("openai/modules/discord.lua")
end
include("openai/modules/enum_color.lua")
include("openai/modules/httpcode.lua")


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


local cfg_folder = "openai"
function OpenAI.FileReset()

    local cfg_file = cfg_folder .. "/openai_config.txt"

    if not file.Exists(cfg_folder, "DATA") then
        file.CreateDir(cfg_folder)
    end

    if file.Exists(cfg_file, "DATA") then
        file.Delete(cfg_file)
    end

    HTTP({
        method          = "GET",
        url             = "https://raw.githubusercontent.com/vicentefelipechile/openai-gmod/main/data/openai/openai_config.txt",
        success         = function(code, body)
                            local fCode = OpenAI.HTTPcode[code] or function() MsgC(code) end
                            fCode()

                            file.Write(cfg_file, body)
                        end,
        failed          = function(msg)
                            MsgC("Error al descargar el archivo:", msg, "\n")
        end
    })

end

if SERVER then
    concommand.Add("openai_config_resetall", OpenAI.FileReset, _, "Reset to default config")

    if not file.Exists(cfg_folder .. "/openai_config.txt", "DATA") then
        OpenAI.FileReset()
    end
end



local trim = string.Trim
local start = string.StartsWith

if SERVER then
    function OpenAI.FileRead()
        local cfg = {}
        local cfg_file = file.Open(cfg_folder .. "/openai_config.txt", "r", "DATA")
    
        if cfg_file == nil then return OpenAI.default end
    
        while not cfg_file:EndOfFile() do
            local line = trim( cfg_file:ReadLine() )
    
            if line == "" or string.sub(line, 1, 1) == "#" then continue end
    
            local key, value = string.match(line, "(%S+):%s*(.*)")
            if key == nil or value == nil then continue end
    
            key, value = string.lower( trim(key) ), trim(value)
    
            cfg[key] = cfg[key] or value
        end
    
        cfg_file:Close()
    
        for k, v in pairs( OpenAI.default ) do
            if cfg[k] == nil then
                cfg[k] = v
            end
        end
    
        return cfg
    end
end

do
    if not file.Exists("openai/openai_config.txt") then
        HTTP({
            method          = "GET",
            url             = "https://raw.githubusercontent.com/vicentefelipechile/openai-gmod/main/data/openai/openai_config.txt",
            success         = function(code, body)
                                local fCode = OpenAI.HTTPcode[code] or function() MsgC(code) end
                                fCode()

                                file.Write(cfg_file, body)
                            end,
            failed          = function(msg)
                                MsgC("Error al descargar el archivo:", msg, "\n")
            end
        })
    end
end


--[[----------------------------
        Post-Include Files
----------------------------]]--
include("openai/modules/chat.lua")
include("openai/modules/dalle.lua")
include("openai/modules/discord.lua")
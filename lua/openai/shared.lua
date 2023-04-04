--[[----------------------------------------------------------------------------
                                Shared OpenAI
----------------------------------------------------------------------------]]--


--[[----------------------------
        Include Files
----------------------------]]--
if SERVER then
    AddCSLuaFile("openai/modules/enum_color.lua")
    AddCSLuaFile("openai/modules/httpcode.lua")
    include("openai/server/default.lua")
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
                            local fCode = OpenAI.HTTPcode[code] or function() OpenAI.print(code) end
                            fCode()

                            file.Write(cfg_file, body)
                        end,
        failed          = function(msg)
                            OpenAI.print("Error al descargar el archivo:")
                            OpenAI.print(msg)
        end
    })

end


local trim = string.Trim
local start = string.StartsWith

function OpenAI.FileRead()
    local cfg = {}
    local cfg_file = file.Read(cfg_folder .. "/openai_config.txt", "DATA")

    if cfg_file == nil then return OpenAI.default end

    while not cfg_file:EndOfFile() do
        local line = trim( cfg_file:ReadLine() )

        if line == "" or string.sub(line, 1, 1) == "#" then continue end

        local key, value = string.match(line, "(%S+):%s*(.*)")
        if key == nil or value == nil then continue end

        key, value = string.lower( trim(key) ), trim(value)
        value = tonumber(value) or value

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
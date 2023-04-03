--[[----------------------------------------------------------------------------
                                Shared OpenAI
----------------------------------------------------------------------------]]--


--[[----------------------------
        Include Files
----------------------------]]--
if SERVER then
    AddCSLuaFile("openai/modules/enum_color.lua")
    AddCSLuaFile("openai/modules/httpcode.lua")

    include("openai/server/reqwest.lua")
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
                            if code == 200 then
                                OpenAI.print(code, " - Archivo de configuracion descargado con exito!!")
                            else
                                OpenAI.print(code, " - Error al descargar el archivo")
                            end
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

    if cfg_file == nil then return end

    while not cfg_file:EndOfFile() do
        local line = trim( cfg_file:ReadLine() )

        if line == "" then continue end
        if string.sub(line, 1, 1) == "#" then continue end

        local key, value = string.match(line, "(%S+):%s*(.*)")
        if key == nil or value == nil then continue end

        key, value = trim(key), trim(value)
        value = tonumber(value) or value

        cfg[string.lower(key)] = cfg[string.lower(key)] or value
    end

    return cfg
end
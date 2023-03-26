--[[----------------------------------------------------------------------------
                                Shared OpenAI
----------------------------------------------------------------------------]]--

function OpenAI.print(...)
    local color = color or SERVER and Color(123, 250, 250) or Color(212, 250, 123)

    MsgC(Color(255, 255, 255), unpack({...}))
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

    http.Fetch("https://raw.githubusercontent.com/vicentefelipechile/openai-gmod/main/data/openai/openai_config.txt",
    
        function(body, _, _, code)
            OpenAI.print(code, " - Archivo de configuracion descargado con exito!!")
            file.Write(cfg_file, body)
        end,
        
        function(msg)
            OpenAI.print("Error al descargar el archivo:")
            OpenAI.print(msg)
        end

    )

end

local trim = string.Trim
local start = string.StartsWith

function OpenAI.FileRead()
    local cfg = {}
    local cfg_file = file.Open(cfg_folder .. "/openai_config.txt")

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
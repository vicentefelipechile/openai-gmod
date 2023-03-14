--[[----------------------------------------------------------------------------
                                Shared OpenAI
----------------------------------------------------------------------------]]--

function OpenAI.print(...)
    local color = color or SERVER and Color(123, 250, 250) or Color(212, 250, 123)

    MsgC(Color(255, 255, 255), unpack({...}))
end


local cfg_folder = "openai"
function OpenAI.FileReset()

    local cfg_file = cfg_folder .. "/config.txt"

    if not file.Exists(cfg_folder, "DATA") then
        file.CreateDir(cfg_folder)
    end

    if file.Exists(cfg_file, "DATA") then
        file.Delete(cfg_file)
    end

    http.Fetch("https://raw.githubusercontent.com/vicentefelipechile/openai-gmod/main/data/openai/openai_token.txt",
    
        function(body, _, _, code)
            OpenAI.print(code .. " - Archivo de configuracion descargado con exito!!")
            file.Write(cfg_file, body)
        end,
        
        function(msg)
            OpenAI.print("Error al descargar el archivo:")
            OpenAI.print(msg)
        end

    )

end

function OpenAI.FileRead()
    local cfg = {}
    local cfg_file = file.Open("")

    while not  do
        
    end
end
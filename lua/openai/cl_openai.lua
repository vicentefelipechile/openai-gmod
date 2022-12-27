--[[---------------------------------------------------------
    OpenAI Client-side Script
-----------------------------------------------------------]]

CreateClientConVar("openai_downloadimg", 1, true, true, "Should download images from server?", 0, 1)

local cAT = chat.AddText

function openai.sendData(_, _, args, str)
    if not args[2] then
        return openai.print("Error - Argumentos insuficientes")
    end

    local l = args[1] .. " "
    local prompt = string.sub(str, #l + 1, -1)

    if #prompt <= 9 then
        return openai.print("Error - Texto insuficiente")
    end

    net.Start("OpenAI.CLtoSV")
        net.WriteString(args[1])
        net.WriteString(prompt)
    net.SendToServer()

end

function openai.typeData(cmd, args)
    return {
        cmd .. " createCompletion",
        cmd .. " createImage",
    }
end

concommand.Add("openai", openai.sendData, openai.typeData)

hook.Add("OnPlayerChat", "OpenAI.ChatCommand", function(ply, text)
    if not ( ply == LocalPlayer() ) then return end

    text = string.Trim(string.lower(text))

    if string.StartWith(text, "!ai ") or string.StartWith(text, "!ia ") then
        local prompt = string.sub(text, 5)
        LocalPlayer():ConCommand("openai createCompletion " .. prompt)
    end

    if string.StartWith(text, "!img ") then
        local prompt = string.sub(text, 6)
        LocalPlayer():ConCommand("openai createImage " .. prompt)
    end
end)

--[[---------------------------------------------------------
    OpenAI Functions
-----------------------------------------------------------]]

function openai.createDir()
    return file.Exists("openai", "DATA") or file.CreateDir("openai") and openai.print("The directory has been created succesful!")
end
openai.createDir()

local noValid = "<>:\"/\\|?*"

function openai.writeImage(image, prompt)
    if not image then return end

    prompt = string.gsub( string.sub(prompt, 1, 48), " ", "_" )

    for i=1, #prompt do
        local char = string.gsub(prompt, i, i)
        if string.find(noValid, char) then
            prompt = string.gsub(prompt, char, "_")
        end
    end

    local filename = os.time() .. "_" .. prompt .. ".png"

    file.Write("openai/" .. filename, image)
    openai.print("File saved succesful!")
    openai.print("Saved as: " .. filename)
end

--[[---------------------------------------------------------
    OpenAI Network Functions
-----------------------------------------------------------]]

net.Receive("OpenAI.SVtoCL", function()
    local bytes = net.ReadUInt(16)
    local data_compressed = net.ReadData( bytes )
    local data = util.Decompress(data_compressed)
    local prompt = net.ReadString()
    
    -- openai.print(data, Color(237, 255, 101))
    cAT(Color(255, 255, 255), "[OpenAI] Entrada: ", Color(81, 173, 173),  prompt)
    cAT(Color(255, 255, 255), "[OpenAI] Salida: ", Color(59, 183, 255),  data)
end)

net.Receive("OpenAI.IMGtoCL", function()
    if not GetConVar("openai_downloadimg"):GetBool() then return end

    openai.print("Url received succesful!")
    local url = net.ReadString()
    local prompt = net.ReadString()

    HTTP({
        ["url"]         = url,
        ["method"]      = "GET",
        ["headers"]     = {},

        ["success"]     = function(code, body, headers)
            openai.code(code)

            openai.writeImage(body, prompt)
        end,

        ["failed"]      = function(error)
            openai.print(error)
        end
    })

    openai.print("Downloading...")
end)
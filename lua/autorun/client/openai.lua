--[[---------------------------------------------------------
	OpenAI Client-side Script
-----------------------------------------------------------]]

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
        net.WriteString(a[1])
        net.WriteString(prompt)
    net.SendToServer()

end

function openai.typeData(cmd, args)
    local tbl = {
        cmd .. " createCompletion",
        cmd .. " createImage",
    }

    return tbl
end

concommand.Add("openai", openai.sendData, openai.typeData)

hook.Add("OnPlayerChat", "OpenAI.ChatCommand", function(ply, text)
    if not ( ply == LocalPlayer() ) then return end

    text = string.Trim(text)

    if string.StartWith(text, "!ai ") or string.StartWith(text, "!ia ") then
        local prompt = string.sub(text, 5, -1)
        LocalPlayer():ConCommand("openai createCompletion " .. prompt)
    end
end)

net.Receive("OpenAI.SVtoCL", function()
    local bytes = net.ReadUInt(16)
    local data_compressed = net.ReadData( bytes )
    local data = util.Decompress(data_compressed)
	local prompt = net.ReadString()
    
    openai.print(data, Color(237, 255, 101))
    cAT(Color(255, 255, 255), "[OpenAI] Entrada: ", Color(81, 173, 173),  prompt)
    cAT(Color(255, 255, 255), "[OpenAI] Salida: ", Color(59, 183, 255),  data)
end)
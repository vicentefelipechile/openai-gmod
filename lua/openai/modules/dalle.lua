--[[----------------------------------------------------------------------------
                                Dalle Module
----------------------------------------------------------------------------]]--

if SERVER then
    util.AddNetworkString("openai.imageCLtoSV")
    util.AddNetworkString("openai.imageSVtoCL")
end

if CLIENT then
    CreateConVar("openai_image_download", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE}, "Deberias descargar las imagenes del servidor?", 0, 1)
    CreateClientConVar("openai_image_namelength", 32, true, true, "El nombre maximo que puede tener el archivo", 8, 64)

    function OpenAI.imageSetFileName(prompt)
        local maxLength = GetConVar("openai_image_namelength"):GetInt()
        local unixtime = os.time()
        local name = prompt:gsub("[%p%c]", ""):gsub("%s+", "_")
        
        if name:len() > maxLength then
            name = name:sub(1, maxLength)
        end
        
        return string.format("%d_%s.png", unixtime, name)
    end


    if not file.Exists("openai/image", "DATA") then
        file.CreateDir("openai/image")
    end


    net.Receive("openai.imageSVtoCL", function()
        local ply = net.ReadEntity()
        local url = net.ReadString()
        local prompt = net.ReadString()

        HTTP({
            method = "GET",
            url = url,
            
            success = function(code, image)
                local fCode = OpenAI.HTTPcode[code] or function() MsgC(code) end
                fCode()

                if code == 200 then
                    local name = OpenAI.imageSetFileName(prompt)
                    file.Write("openai/image/" .. name, image)
                end
            end
        })
    end)

    return
end

--[[------------------------
      Local Definitions
------------------------]]--


local cfg = OpenAI.FileRead()
local API = cfg["openai"] or false

local header = API and {
    ["Authorization"] = "Bearer " .. API,
}

local c_error = COLOR_RED
local c_normal = COLOR_SERVER


local function getPlayersToSend()
    local tbl = {}

    for _, ply in ipairs( player.GetAll() ) do
        if ply:GetInfoNum("openai_image_download", 0) == 1 then
            table.insert(tbl, ply)
        end
    end

    return tbl
end

--[[------------------------
        Main Scripts
------------------------]]--

function OpenAI.chatFetch(ply, msg)
    if not API then return end

    local body = {
        prompt  = msg,
        size    = cfg["image_size"],
        user    = OpenAI.replaceSteamID( cfg["image_user"], ply ),
    }

    local jsonBody = util.TableToJSON(body)

    OpenAI.HTTP("images", jsonBody, header, function(code, body)
        local fCode = OpenAI.HTTPcode[code] or function() MsgC(code) end
        fCode()

        if code == 200 then
            json = util.JSONToTable( string.Trim( body ) )

            local response = json["data"][0][url]

            net.Start("openai.imageSVtoCL")
                net.WriteEntity(ply)
                net.WriteString(response)
                net.WriteString(msg)
            net.Send( getPlayersToSend() )
        end
    end,
    function(err)
        MsgC(COLOR_RED, err)
    end)
end
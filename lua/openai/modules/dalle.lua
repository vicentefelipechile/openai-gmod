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
                    local name = "openai/image/" .. OpenAI.imageSetFileName(prompt)
                    file.Write(name, image)

                    hook.Call("OpenAI.onImageDownloaded", nil, ply, name, prompt)
                end
            end
        })

        hook.Call("OpenAI.onImageReceive", nil, ply, url, prompt)
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

local download = CreateConVar("openai_image_downloadserver", 1, FCVAR_ARCHIVE, "Should the server download the images?", 0, 1)
function OpenAI.imageFetch(ply, msg)
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

            local response = json["data"][1]["url"]

            net.Start("openai.imageSVtoCL")
                net.WriteEntity(ply)
                net.WriteString(response)
                net.WriteString(msg)
            net.Send( getPlayersToSend() )

            hook.Call("OpenAI.imageFetch", nil, ply, msg, response)
        end
    end,
    function(err)
        MsgC(COLOR_RED, err)
    end)
end


concommand.Add("openai_image_reloadconfig", function()
    cfg = OpenAI.FileRead()
end)


--[[------------------------
      Commands Scripts
------------------------]]--

local cases = {
    [0] = function(ply, prompt)
        if ulx then
            return
        else
            OpenAI.imageFetch(ply, prompt)
        end
    end,

    [1] = function(ply, prompt)
        OpenAI.imageFetch(ply, prompt)
    end,

    [2] = function(ply, prompt)
        if ply:IsAdmin() then
            OpenAI.imageFetch(ply, prompt)
        end
    end,

    [3] = function(ply, prompt)
        if ply:IsSuperAdmin() then
            OpenAI.imageFetch(ply, prompt)
        end
    end,

    [4] = function(ply, prompt)
        
    end
}


local image_show = CreateConVar("openai_image_noshow", 0, FCVAR_ARCHIVE, "Should show the command in the chat?", 0, 1)
hook.Add("PlayerSay", "OpenAI.image", function(ply, text)

    local cmd, prompt = OpenAI.handleCommands(text)
    if cmd == nil or cmd ~= "dalle" then return end
    
    local permissionType = GetConVar("openai_admin"):GetInt()
    local fn = cases[permissionType] or function() end

    fn(ply, prompt)

    return image_show:GetBool() and "" or text
end)
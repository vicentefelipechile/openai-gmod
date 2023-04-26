--[[----------------------------------------------------------------------------
                                Dalle Module
----------------------------------------------------------------------------]]--

local function GetPath()
    return string.GetFileFromFilename( debug.getinfo(1, "S")["short_src"] )
end

local image_show = CreateConVar("openai_image_noshow", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Should show the command in the chat?", 0, 1)

if SERVER then
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
                OpenAI.HandleCode(code, GetPath())

                if code == 200 then
                    local path = "openai/image/" .. OpenAI.imageSetFileName(prompt)
                    file.Write(path, image)

                    hook.Call("OpenAI.onImageDownloaded", nil, ply, path, prompt)
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

function OpenAI.imageFetch(ply, msg)

    local canUse = hook.Run("OpenAI.imagePlyCanUse", ply)
    if canUse == false then return end

    local cfg = OpenAI.FileRead()

    local body = {
        prompt  = msg,
        size    = cfg["image_size"],
        user    = OpenAI.replaceSteamID( cfg["image_user"], ply ),
    }

    local openai = OpenAI.Request()
    openai:SetType("images")
    openai:SetBody(body)
    openai:SetSuccess(function(code, body)
        OpenAI.HandleCode(code, GetPath())

        local json = util.JSONToTable(body)

        if code == 200 then
            local response = json["data"][1]["url"]

            net.Start("openai.imageSVtoCL")
                net.WriteEntity(ply)
                net.WriteString(response)
                net.WriteString(msg)
            net.Send( getPlayersToSend() )

            hook.Call("OpenAI.imageFetch", nil, ply, msg, response)
        elseif code == 400 then
            mError = json["error"]["message"]
            MsgC(COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] ", COLOR_RED, mError, "\n")

            if GetConVar("openai_displayerrorcl"):GetBool() then
                net.Start("OpenAI.errorToCL")
                    net.WriteString(json["error"]["message"])
                net.Send(ply)
            end
        end
    end)

    openai:SendRequest()
end


--[[------------------------
      Commands Scripts
------------------------]]--

hook.Add("OpenAI.imagePlyCanUse", "OpenAI.imagePlyCanUse", function(ply)
    
    local admin = GetConVar("openai_admin"):GetInt()
    local canUse = false

    if admin == 1 then
        canUse = true
    elseif admin == 2 then
        canUse = ply:IsAdmin()
    elseif admin == 3 then
        canUse = ply:IsSuperAdmin()
    elseif admin == 4 then
        if ULib then
            canUse = ULib.ucl.query(ply, "OpenAI.image")
        end
    end

    return canUse
end)


hook.Add("PlayerSay", "OpenAI.image", function(ply, text)

    local cmd, prompt = OpenAI.handleCommands(text)

    if cmd == nil or cmd ~= "dalle" then return end
    if prompt == nil or #prompt < 1 then return end

    OpenAI.imageFetch(ply, prompt)

    return image_show:GetBool() and "" or text
end)
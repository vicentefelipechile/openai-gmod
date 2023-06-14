--[[----------------------------------------------------------------------------
                                Dalle Module
----------------------------------------------------------------------------]]--

OpenAI.Config.Dalle = {}
OpenAI.Config.Dalle.NoShow = CreateConVar("openai_image_noshow", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Should show the command in the chat?", 0, 1)
OpenAI.Config.Dalle.Size = CreateConVar("openai_image_size", "256x256", {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "What will be the size of the image")


if SERVER then
    util.AddNetworkString("openai.imageSVtoCL")
else
    CreateClientConVar("openai_image_download", 1, true, true, "Download images?", 0, 1)

    net.Receive("openai.imageSVtoCL", function()
        local ply = net.ReadEntity()
        local url = net.ReadString()
        local prompt = net.ReadString()

        HTTP({
            method = "GET",
            url = url,
            
            success = function(code, image)
                OpenAI.HandleCode(code)

                if code == 200 then
                    local path = "openai/image/" .. OpenAI.SetFileName(prompt)
                    file.Write(path, image)

                    hook.Call("OpenAI.OnImageDownloaded", nil, ply, path, prompt)
                end
            end
        })

        hook.Call("OpenAI.OnImageReceive", nil, ply, url, prompt)
    end)

    return
end

--[[------------------------
      Local Definitions
------------------------]]--

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

function OpenAI.ImageFetch(ply, msg)

    local canUse = hook.Run("OpenAI.imagePlyCanUse", ply)
    if canUse == false then return end

    local openai = OpenAI.Request()
    :SetType("images")
    :AddBody("prompt", msg)
    :AddBody("size", OpenAI.Config.Dalle.Size:GetString())
    :AddBody("user", ply)
    :SetSuccess(function(code, body)
        OpenAI.HandleCode(code)

        local json = util.JSONToTable(body)

        if code == 200 then
            local response = json["data"][1]["url"]

            net.Start("openai.imageSVtoCL")
                net.WriteEntity(ply)
                net.WriteString(response)
                net.WriteString(msg)
            net.Send( getPlayersToSend() )

            hook.Call("OpenAI.OnImageReceive", nil, ply, msg, response)

        elseif code == 400 then

            mError = json["error"]["message"]
            MsgC(COLOR_WHITE, " > ", COLOR_RED, mError, "\n")

            if OpenAI.Config.DisplayErrorCL:GetBool() then
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
            canUse = ULib.ucl.query(ply, "openai image")
        end
    end

    return canUse
end)


hook.Add("PlayerSay", "OpenAI.image", function(ply, text)

    local cmd, prompt = OpenAI.HandleCommands(text)

    if cmd == nil or cmd ~= "dalle" then return end
    if prompt == nil or #prompt < 1 then return end

    OpenAI.ImageFetch(ply, prompt)

    return image_show:GetBool() and "" or text
end)
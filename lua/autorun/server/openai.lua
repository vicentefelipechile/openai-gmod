--[[---------------------------------------------------------
    OpenAI Server-side Script
-----------------------------------------------------------]]

openai.allowed = {
    ["createImage"] = { true, "image" },
    ["createCompletion"] = { true, "text" },
}


--[[---------------------------------------------------------
    Fallbacks
-----------------------------------------------------------]]

local APIKEY = file.Read("openai_token.txt", "DATA")
if not APIKEY then return end

local suffix = ({"osx64", "osx", "linux64", "linux", "win64", "win32"})[(system.IsWindows() and 4 or 0) + (system.IsLinux() and 2 or 0) + (jit.arch == "x86" and 1 or 0) + 1]
local fmt    = "lua/bin/gm" .. (CLIENT and "cl" or "sv") .. "_%s_%s.dll"
local function installed(name)
    if file.Exists( string.format(fmt, name, suffix), "GAME" ) then return true end
    if jit.version_num ~= 20004 and jit.arch == "x86" and system.IsLinux() then return file.Exists(string.format(fmt, name, "linux32"), "GAME") end
    return false
end

if not installed("reqwest") then
    openai.print("Error \"Reqwest\" Module isn't installed", Color(255, 50, 50))
    openai.print("Are you sure that is the correct version?")
    return
else
    require("reqwest")
end


--[[---------------------------------------------------------
    OpenAI Main/Core Functions
-----------------------------------------------------------]]


--[[---------------------------------------------------------
    Function:   openai.timer
    Args:       Player, Type

    Player:     The player to set timer
    Type:       Type of text ("image" or "text")
-----------------------------------------------------------]]
function openai.timer(ply, type)
    if not ply:IsPlayer() then return end

    timer.Create( "OpenAI.Timer_" .. tostring(ply:SteamID64()), GetConVar("openai_cooldown_"..type):GetInt(), 1,
    function()
        ply:SetNWBool("OpenAI.cooldown_"..type, false)
    end)
end


--[[---------------------------------------------------------
    Function:   openai.SVtoCL
    Args:       Data, Prompt

    Data:       The data to has to been compress
    Prompt:     Text/prompt to display to everyone
-----------------------------------------------------------]]
function openai.SVtoCL(data, prompt)
    local data = util.Compress(data)
    local bytes = #data

    net.Start("OpenAI.SVtoCL")
        net.WriteUInt( bytes, 16 )
        net.WriteData( data, bytes )
        net.WriteString( prompt )
    net.Broadcast()
end


--[[---------------------------------------------------------
    Function:   openai.gdr
    Args:       Data, Bool

    Data:       Message to send to discord
    Bool:       Display "**Entrada**" else, display "**Salida**"
-----------------------------------------------------------]]
function openai.gdr(data, bool)
    if not prompt then return end

    local output = bool and "**Entrada**: " or "**Salida**: "

    hook.Run("GDR_sendMessage",
    "https://i.imgur.com/LrLSpkT.png",
    "OpenAI",
    output .. data)
end


--[[---------------------------------------------------------
    Function:   openai.reqwest
    Args:       Url, Method, Body, Player, Prompt, Type

    Url:        The url is used to use any available model
    Method:     What http is meant to be use
    Body:       What arguments want to send to server
    Player:     If player is set, then will be sent to all players
    Prompt:     The text to sent to all players
    Type:       Type of text ("image" or "text")
-----------------------------------------------------------]]
function openai.reqwest(url, method, bodyHeader, ply, prompt, aiType)
    local func

    if ply then

        func = function(status, body, headers)
            local json = util.JSONToTable(body)
            local data

            if json["choices"] then
                data = string.Trim(json["choices"][1]["text"])
            elseif json["data"] then
                data = json["data"][1]["url"]
            end

            openai.code( status, _, _, _, true )
            openai.print( data, _, _, _, true )
            openai.table( headers, true )

            openai.SVtoCL(data, prompt)

            if ply:IsPlayer() then

                openai.timer(ply, aiType)

                ply:SetNWBool("OpenAI.cooldown_" .. aiType, true)

                if tGDRConfig and GetConVar("openai_gdr"):GetBool() then
                    openai.gdr(prompt, true)
                    openai.gdr(data)
                end
            end
        end

    else

        func = function(code, body, headers)
            openai.code(code, _, _, _, true)
            openai.print(body)
            openai.table(headers, true)
        end
        
    end

    return {
        url     = openai.url .. url,
        type    = "application/json",
        method  = method,
        timeout = 20,
        headers = {
            ["Authorization"] = "Bearer " .. APIKEY
        },

        body = bodyHeader and openai.TTJ(bodyHeader) or "",

        success = func,

        failed = function(error)
            openai.print("ERROR TRYING TO GET", _, _, _, true)
            openai.print(error, _, _, _, true)
        end
    }
end


--[[---------------------------------------------------------
        GET Functions
-----------------------------------------------------------]]

function openai.listModels()
    reqwest( openai.reqwest( "models", "GET" ) )
end

function openai.retrieveModel(_, _, args)
    if not args[1] then return end

    reqwest( openai.reqwest( "models/" .. args[1], "GET" ) )
end


--[[---------------------------------------------------------
        POST Functions
-----------------------------------------------------------]]

function openai.createCompletion(prompt, ply)

    reqwest(openai.reqwest("completions", "POST", {
        ["model"]           = "text-davinci-002",
        ["prompt"]          = prompt,
        ["temperature"]     = 0.7,
        ["max_tokens"]      = 76,
        ["top_p"]           =  1,
        ["frequency_penalty"]   = 0,
        ["presence_penalty"]    = 0,
    }, ply, prompt, "text" ))

end

function openai.createImage(prompt, ply)

    reqwest(openai.reqwest("images/generations", "POST", {
        ["prompt"]  = prompt,
        ["n"]       = 1,
        ["size"]    = "256x256"
    }, ply, prompt, "image" ))

end

--[[---------------------------------------------------------
        Networking
-----------------------------------------------------------]]

function openai.canuse(ply, cmd)
    if openai.blacklist[ply:SteamID()] then return false end

    local canUse = false
    local cmdType = openai.allowed[cmd][2]

    if ply:GetNWBool("OpenAI.cooldown_text") then canUse = false end
    if ply:GetNWBool("OpenAI.cooldown_image") then canUse = false end

    if GetConVar("openai_everyone"):GetBool() then
        canUse = true
    else
        if ULib then
            canUse = ULib.ucl.query(ply, "OpenAI")
        elseif ply:IsSuperAdmin() then
            canUse = true
        end
    end

    if not openai.allowed[cmd][1] then canUse = false end

    return canUse, cmdType
end

hook.Add("OpenAI.CanUse", "CanUse", openai.canuse)

net.Receive("OpenAI.CLtoSV", function(len, ply)
    local command = net.ReadString()
    local prompt = net.ReadString()

    if #prompt <= 9 then return end

    local use, type = hook.Run("OpenAI.CanUse", ply, command)

    if use then
        openai[command](prompt, ply)
    else
        openai.print(ply:Nick() .. " Intento utilizar OpenAI")
    end
end)

--[[---------------------------------------------------------
        PlayerInitialSpawn
-----------------------------------------------------------]]
hook.Add("PlayerInitialSpawn", "OpenAI.InitSpawn", function(ply)
    ply:SetNWBool("OpenAI.cooldown_text", false)
    ply:SetNWBool("OpenAI.cooldown_image", false)
end)
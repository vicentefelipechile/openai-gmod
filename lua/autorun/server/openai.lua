--[[---------------------------------------------------------
	OpenAI Server-side Script
-----------------------------------------------------------]]

local AHTTP

if pcall(require, "reqwest") and reqwest ~= nil then
	AHTTP = reqwest
else
	AHTTP = HTTP
end


local APIKEY = file.Read("openai_token.txt", "DATA")

if not APIKEY then return end

--[[---------------------------------------------------------
	    GET Functions
-----------------------------------------------------------]]

function openai.listModels()
    AHTTP({
        url     =   openai.url .. "models",
        method  =   "GET",
        headers =   {
            ["Authorization"] = "Bearer "..APIKEY
        },

        success = function(code, body, headers)
            openai.code(code, _, _, _, true)

            print(body)
            openai.table(headers, true)
        end,

        failed = function(error)
            openai.print("ERROR TRYING TO GET", _, _, _, true)
            openai.print(error, _, _, _, true)
        end
    })
end

function openai.retrieveModel(_, _, args)
    
    if not args[1] then return end

    AHTTP({
        url     =   openai.url .. "models/" .. args[1],
        method  =   "GET",
        headers =   {
            ["Authorization"] = "Bearer "..APIKEY
        },

        success = function(code, body, headers)
            openai.code(code, _, _, _, true)

            print(body)
            openai.table(headers, true)
        end,

        failed = function(error)
            openai.print("ERROR TRYING TO GET", _, _, _, true)
            print(error, _, _, _, true)
        end
    })
end


--[[---------------------------------------------------------
	    POST Functions
-----------------------------------------------------------]]

function openai.createCompletion(prompt, ply)
    local data = ""

    reqwest({
        method      = "POST",
        url         = openai.url .. "completions",
        timeout     = 20,

        body        = openai.TTJ({
            ["model"]           = "text-davinci-002",
            ["prompt"]          = prompt,
            ["temperature"]     = 0.7,
            ["max_tokens"]      = 76,
            ["top_p"]           =  1,
            ["frequency_penalty"]   = 0,
            ["presence_penalty"]    = 0
        }),

        type        = "application/json",
        headers     = {
            ["Authorization"] = "Bearer "..APIKEY
        },

        success = function(status, body, headers)
            local request = util.JSONToTable(body)["choices"]
            openai.code(status, _, _, _, true)
            openai.print( string.sub(request[1]["text"], 3, -1) )
            openai.table(headers, true)

            data = string.sub(request[1]["text"], 3, -1)

            if ply:IsPlayer() then
                local data_compressed = util.Compress(data)
                local bytes = #data_compressed

                openai.timer(ply, "image")

                ply:SetNWBool("OpenAI.cooldown_image", true)

                if tGDRConfig and GetConVar("openai_gdr"):GetBool() then
                    hook.Run("GDR_sendMessage",
                    "https://i.imgur.com/LrLSpkT.png",
                    "OpenAI",
                    "**Entrada**: " .. prompt)

                    hook.Run("GDR_sendMessage",
                    "https://i.imgur.com/LrLSpkT.png",
                    "OpenAI",
                    "**Salida**: " .. data)
                end

                net.Start("OpenAI.SVtoCL")
                    net.WriteUInt( bytes, 16 )
                    net.WriteData( data_compressed, bytes)
					net.WriteString( prompt )
				net.Broadcast()
                --net.Send(ply)
            end
        end,
        
        failed = function(err, errExt)
            openai.print(error, _, _, _, true)
            openai.print(errExt, _, _, _, true)
        end
    })

    return data, "text"
end

function openai.createImage(prompt, ply)
    local data = ""

    reqwest({
        method  = "POST",
        url     =   openai.url .. "images/generations",
        timeout = 20,

        body    = openai.TTJ({
            ["prompt"]  = prompt,
            ["n"]       = 1,
            ["size"]    = "256x256"
        }),
        type        = "application/json",
        headers     = {
            ["Authorization"] = "Bearer "..APIKEY
        },

        success = function(status, body, headers)
            local request = util.JSONToTable(body)
            PrintTable(request)
    
            openai.code(status, _, _, _, true)

            if status == 200 then

            openai.print(request["data"][1]["url"])
            openai.table(headers, true)

            data = request["data"][1]["url"]

            if ply:IsPlayer() then
                local data_compressed = util.Compress(data)
                local bytes = #data_compressed

                openai.timer(ply, "text")

                ply:SetNWBool("OpenAI.cooldown_text", true)

                net.Start("OpenAI.SVtoCL")
                    net.WriteUInt( bytes, 16 )
                    net.WriteData( data_compressed, bytes)
                net.Send(ply)
            end

            end
        end,
        
        failed = function(err, errExt)
            openai.print(error, _, _, _, true)
            openai.print(errExt, _, _, _, true)

            data = "ERROR"
        end
    })

    return data, "image"
end

function openai.timer(ply, type)
    if not ply:IsPlayer() then return end

    timer.Create( "OpenAI.Timer_" .. tostring(ply:SteamID64()), GetConVar("openai_cooldown_"..type):GetInt(), 1,
        function()
            ply:SetNWBool("OpenAI.cooldown_"..type, false)
        end)
end

--[[---------------------------------------------------------
	    Networking
-----------------------------------------------------------]]

openai.allowed = {
    ["createImage"] = false,
    ["createCompletion"] = true,
}

openai.blacklist = {
    ["STEAM_0:0:619402913"] = false,
}

net.Receive("OpenAI.CLtoSV", function(len, ply)
    if openai.blacklist[ply:SteamID()] then return end

    local CMD    = net.ReadString()
    local PROMPT = net.ReadString()

    if #PROMPT <= 9 then return end

    if ply:GetNWBool("OpenAI.cooldown_text") then return end
    if ply:GetNWBool("OpenAI.cooldown_image") then return end

    if not openai.allowed[CMD] then return end

    openai[CMD](PROMPT, ply)
end)

--[[---------------------------------------------------------
	    PlayerInitialSpawn
-----------------------------------------------------------]]
hook.Add("PlayerInitialSpawn", "OpenAI.InitSpawn", function(ply)
    ply:SetNWBool("OpenAI.cooldown_text", false)
    ply:SetNWBool("OpenAI.cooldown_image", false)
end)
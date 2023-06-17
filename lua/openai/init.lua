--[[----------------------------------------------------------------------------
                                Server-side OpenAI
----------------------------------------------------------------------------]]--

util.AddNetworkString("OpenAI.errorToCL")
util.AddNetworkString("OpenAI.SVtoCL")

--[[------------------------
     Request Definitions
------------------------]]--

OpenAI.REQUESTS = {
    -- Main
    ["models"]      = {"GET", "https://api.openai.com/v1/models"},                  -- https://platform.openai.com/docs/api-reference/models
    ["completions"] = {"POST", "https://api.openai.com/v1/completions"},            -- https://platform.openai.com/docs/api-reference/completions
    ["chat"]        = {"POST", "https://api.openai.com/v1/chat/completions"},       -- https://platform.openai.com/docs/api-reference/chat
    ["images"]      = {"POST", "https://api.openai.com/v1/images/generations"},     -- https://platform.openai.com/docs/api-reference/images

    -- Others
    ["embeddings"]  = {"POST", "https://api.openai.com/v1/embeddings"},             -- https://platform.openai.com/docs/api-reference/embeddings
    ["transcription"]= {"POST", "https://api.openai.com/v1/audio/transcriptions"},  -- https://platform.openai.com/docs/api-reference/audio/create
    ["translation"] = {"POST",  "https://api.openai.com/v1/audio/translations"},    -- https://platform.openai.com/docs/api-reference/audio/create
    ["moderation"]  = {"POST",  "https://api.openai.com/v1/moderations"},           -- https://platform.openai.com/docs/api-reference/moderations/create

    -- Files
    ["list"]        = {"GET", "https://api.openai.com/v1/files"},                   -- https://platform.openai.com/docs/api-reference/files/list
    ["upload"]      = {"POST", "https://api.openai.com/v1/files"},                  -- https://platform.openai.com/docs/api-reference/files/upload
    ["delete"]      = {"DELETE", "https://api.openai.com/v1/files/"},               -- https://platform.openai.com/docs/api-reference/files/delete
    ["retrieve"]    = {"GET", "https://api.openai.com/v1/files/"},                  -- https://platform.openai.com/docs/api-reference/files/retrieve
}

--[[------------------------
     Convar Definitions
------------------------]]--

OpenAI.Config.APIKEY = CreateConVar("openai_apikey", "YOUR_APIKEY_HERE", {FCVAR_ARCHIVE, FCVAR_DONTRECORD, FCVAR_PROTECTED, FCVAR_UNLOGGED}, "Set your api key here")
OpenAI.Config.PlayerFormat = CreateConVar("openai_playerformat", "[steamid]", FCVAR_ARCHIVE)

--[[------------------------
        Util Scripts
------------------------]]--

function OpenAI.SendError(ply, msg)
    net.Start("OpenAI.errorToCL")
        net.WriteString(msg)
    net.Send(ply)
end

function OpenAI.SendMessage(ply, prompt, response, namehook, prefix)
    if not IsValid(ply) then ply = NULL end
    if not ply:IsPlayer() then ply = NULL end

    net.Start("OpenAI.SVtoCL")
        net.WriteEntity(ply)
        net.WriteString(prompt)
        net.WriteString(response)
        net.WriteString(namehook)
        net.WriteString(prefix or "OpenAI")
    net.Broadcast()
end

function OpenAI.GetAPI()
    local API = OpenAI.Config.APIKEY:GetString()

    local header = API == "YOUR_APIKEY_HERE" and {} or { 
        ["Authorization"] = "Bearer " .. API,
    }

    return header
end

-- Generate by AI
function OpenAI.IntToJson(field, json)
    local pattern = [["]] .. field .. [[":(%d+%.?%d*)]]
    local fieldValue = string.match(json, pattern)

    if fieldValue then
        local fieldNumber = tonumber(fieldValue)
        fieldNumber = math.floor(fieldNumber)
        local convertedJsonString = string.gsub(json, pattern, [["]] .. field .. [[":]] .. fieldNumber)
        return convertedJsonString
    else
        return json
    end
end

function OpenAI.ReplaceSteamID(text, ply)
    if string.find(text, "%[steamid%]") then
        text = string.gsub(text, "%[steamid%]", ply:SteamID())
    end

    if string.find(text, "%[steamid64%]") then
        text = string.gsub(text, "%[steamid64%]", ply:SteamID64())
    end

    return text
end


--[[------------------------
        Server Scripts
------------------------]]--

include("openai/server/modules.lua")
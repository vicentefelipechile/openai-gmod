--[[----------------------------------------------------------------------------
                                Server-side OpenAI
----------------------------------------------------------------------------]]--

util.AddNetworkString("OpenAI.errorToCL")
include("openai/server/default.lua")

--[[------------------------
      Local Definitions
------------------------]]--

local trim = string.Trim
local start = string.StartsWith

local REQUESTS = {
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

OpenAI.REQUESTS = REQUESTS

local c_ok = COLOR_GREEN
local c_error = COLOR_RED
local c_normal = COLOR_SERVER
local c_important = COLOR_MENU

local folder = "openai"


--[[------------------------
        Util Scripts
------------------------]]--


function OpenAI.FileRead()
    local cfg = {}
    local cfg_file = file.Open(folder .. "/openai_config.txt", "r", "DATA")

    if cfg_file == nil then return OpenAI.default end

    while not cfg_file:EndOfFile() do
        local line = trim( cfg_file:ReadLine() )

        if line == "" or string.sub(line, 1, 1) == "#" then continue end

        local key, value = string.match(line, "(%S+):%s*(.*)")
        if key == nil or value == nil then continue end

        key, value = string.lower( trim(key) ), trim(value)
        if tonumber(value) then
            value = tonumber(value)
        end

        cfg[key] = cfg[key] or value
    end

    cfg_file:Close()

    for k, v in pairs( OpenAI.default ) do
        if cfg[k] == nil then
            cfg[k] = v
        end
    end

    return cfg
end


function OpenAI.GetAPI()
    local API = OpenAI.FileRead()["openai"] or false

    local header = API == false and {} or { 
        ["Authorization"] = "Bearer " .. API,
    }
    return header
end

function OpenAI.GetConfig(str)
    return OpenAI.FileRead()[str]
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
OpenAI.replaceSteamID = OpenAI.ReplaceSteamID


--[[------------------------
        Server Scripts
------------------------]]--

include("openai/server/modules.lua")
--[[----------------------------------------------------------------------------
                                Server-side OpenAI
----------------------------------------------------------------------------]]--

util.AddNetworkString("OpenAI.errorToCL")
include("openai/server/reqwest.lua")

--[[------------------------
      Local Definitions
------------------------]]--

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

local cfg = OpenAI.FileRead()

--[[------------------------
        Server Scripts
------------------------]]--

function OpenAI.HTTP(request, body, headers, onsuccess, onfailure, context)
    if not REQUESTS[request] then MsgC(c_error, "ERROR", c_normal, ": The request type isn't valid or isn't allowed") return end

    local method, url = REQUESTS[request][1], REQUESTS[request][2]

    if not context == nil then
        url = url .. context
    end

    reqwest({
        url = url,
        body = body or util.TableToJSON({}),
        method = method,
        headers = headers or {},
        type = "application/json",
        timeout = 25,

        success = function(code, body, headers)
            if ( !onsuccess ) then return end
            onsuccess( code, body, headers )
        end,
      
        failed = function( err )
            if ( !onfailure ) then return end
            onfailure( err )
        end
    })
end


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

function OpenAI.replaceSteamID(text, ply)
    if string.find(text, "%[steamid%]") then
        text = string.gsub(text, "%[steamid%]", ply:SteamID())
    end

    if string.find(text, "%[steamid64%]") then
        text = string.gsub(text, "%[steamid64%]", ply:SteamID64())
    end

    return text
end
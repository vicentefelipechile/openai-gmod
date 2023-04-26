--[[----------------------------------------------------------------------------
                                Server-side OpenAI
----------------------------------------------------------------------------]]--

util.AddNetworkString("OpenAI.errorToCL")
--include("openai/server/reqwest.lua")

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


--[[------------------------
        Util Scripts
------------------------]]--

function OpenAI.GetAPI()
    local API = OpenAI.FileRead()["openai"] or false

    local header = API == false and {} or { 
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


function OpenAI.replaceSteamID(text, ply)
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

local openai = {

    request = {
        url = "https://api.openai.com",
        body = util.TableToJSON({}),
        method = "GET",
        headers = OpenAI.GetAPI(),
        type = "application/json",
        timeout = 25,
        success = function() end,
        failed = function() MsgC(COLOR_RED, err, "\n") end,
    },

    SetType = function(self, type)
        if not REQUESTS[type] then return end

        local method, url = REQUESTS[type][1], REQUESTS[type][2]
        self.request["method"] = method
        self.request["url"] = url
    end,

    GetType = function(self)
        return self.request["method"], self.request["url"]
    end,

    SetBody = function(self, body)
        if not istable(body) then return end

        local jsonBody = util.TableToJSON(body)
        if body["max_tokens"] then
            jsonBody = OpenAI.IntToJson( "max_tokens", jsonBody )
        end

        self.request["body"] = jsonBody
    end,

    GetBody = function(self)
        return self.request["body"]
    end,

    SetSuccess = function(self, func)
        if not isfunction(func) then return end

        self.request["success"] = func
    end,

    SetFailed = function(self, func)
        if not isfunction(func) then return end

        self.request["failed"] = func
    end,

    GetAll = function(self)
        local all = table.Copy(self.request)
        if all["headers"] and all["headers"]["Authorization"] then
            all["headers"]["Authorization"] = "***PROTECTED***"
        end

        return all
    end,

    SendRequest = function(self)
        local req = self.request

        HTTP(req)
    end
}
openai.__index = openai


function OpenAI.Request()
    return setmetatable( { [ 0 ] = 0 }, openai)
end


function OpenAI.HTTP(request, body, headers, onsuccess, onfailure, context)
    if not REQUESTS[request] then MsgC(c_error, "ERROR", c_normal, ": The request type isn't valid or isn't allowed") return end

    local method, url = REQUESTS[request][1], REQUESTS[request][2]

    if not context == nil then
        url = url .. context
    end

    HTTP({
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
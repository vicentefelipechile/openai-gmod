--[[----------------------------------------------------------------------------
                                Server-side OpenAI
----------------------------------------------------------------------------]]--

include("openai/server/reqwest.lua")

--[[------------------------
      Local Definitions
------------------------]]--

local REQUESTS = {
    ["models"]      = {"GET", "https://api.openai.com/v1/models"},                  -- https://platform.openai.com/docs/api-reference/models
    ["completions"] = {"POST", "https://api.openai.com/v1/completions"},            -- https://platform.openai.com/docs/api-reference/completions
    ["chat"]        = {"POST", "https://api.openai.com/v1/chat/completions"},       -- https://platform.openai.com/docs/api-reference/chat
    ["images"]      = {"POST", "https://api.openai.com/v1/images/generations"},     -- https://platform.openai.com/docs/api-reference/images
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

function OpenAI.JSONEncode(tbl)
    if not istable(tbl) then return end

    local json = "{"

    for k, v in pairs(tbl) do
        json = isnumber(v) and json .. "\"" .. k .. "\":" .. v .. "," or json .. "\"" .. k .. "\":\"" .. v .. "\","
    end
    
    json = string.sub(json, 0, -2) .. "}"

    return json
end


function OpenAI.HTTP(request, body, headers, onsuccess, onfailure)
    if not REQUESTS[request] then MsgC(c_error, "ERROR", c_normal, ": The request type isn't valid or isn't allowed") return end

    local method, url = REQUESTS[request][1], REQUESTS[request][2]

    reqwest({
        url = url,
        body = body or {},
        method = method,
        headers = headers or {},
        type = "application/json",
        timeout = 10,

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

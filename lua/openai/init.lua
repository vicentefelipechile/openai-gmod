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

local c_ok = COLOR_GREEN
local c_error = COLOR_RED
local c_normal = COLOR_WHITE
local c_important = COLOR_MENU

local folder = "openai"



--[[------------------------
        Server Scripts
------------------------]]--

function OpenAI.HTTP(request, info)
    
end
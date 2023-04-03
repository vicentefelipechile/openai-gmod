--[[----------------------------------------------------------------------------
                                Server-side OpenAI
----------------------------------------------------------------------------]]--


--[[------------------------
      Local Definitions
------------------------]]--

local REQUESTS = {
    ["Models"] = true,          -- https://platform.openai.com/docs/api-reference/models
    ["Completions"] = true,     -- https://platform.openai.com/docs/api-reference/completions
    ["Chat"] = true,            -- https://platform.openai.com/docs/api-reference/chat
    ["Images"] = true,          -- https://platform.openai.com/docs/api-reference/images
}

local c_ok = COLOR_GREEN
local c_error = COLOR_RED
local c_normal = COLOR_WHITE
local c_important = COLOR_MENU

local reqwesturl = "https://github.com/WilliamVenner/gmsv_reqwest/releases/tag/v3.0.2/"
local cfg_folder = "openai"



--[[------------------------
        Server Scripts
------------------------]]--
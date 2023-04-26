--[[----------------------------------------------------------------------------
                                Default configuration
----------------------------------------------------------------------------]]--


local trim = string.Trim
local start = string.StartsWith


--[[------------------------
        Configuration
------------------------]]--

OpenAI.default = OpenAI.default or {

    image_size = "256x256",
    image_user = "[steamid]",

    chat_model = "gpt-3.5-turbo",
    chat_temperature = 1,
    chat_max_tokens = 24,
    chat_user = "[steamid]",

    translator_model = "gpt-3.5-turbo",
    translator_temperature = 1,
    translator_max_tokens = 24,
    translator_user = "[steamid]",
    translator_cmd = ",",

    discord_avatar = "https://i.imgur.com/wmTcTkk.png",
    discord_name = "OpenAI"
}

OpenAI.default_cfg = OpenAI.default_cfg or [[
# API Token
OpenAI: sk-XXXXXXXXXXXXXXXXXXXXX


# Images configuracion
Image_size: 256x256
Image_user: [steamid]


# Chat configuracion
Chat_model: gpt-3.5-turbo
Chat_temperature: 1
Chat_max_tokens: 24
Chat_user: [steamid]

# Translator configuracion
Translator_model: gpt-3.5-turbo
Translator_temperature: 1
Translator_max_tokens: 24
Translator_user: [steamid]
Translator_cmd: ,


# Discord Webhook
Discord_webhook: https://discord.com/api/webhooks/
Discord_avatar: https://i.imgur.com/wmTcTkk.png
Discord_name: OpenAI

# https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks



# Formatos permitidos
#
# [steamid] = STEAM_X_XXXXXXXXXX
# [steamid64] = 765XXXXXXXXXXXXX
# [first_message] = El mensaje colocado en el chat

# Revisa mas aqui V
# https://platform.openai.com/docs/models/model-endpoint-compatibility
]]



--[[------------------------
        Main Scripts
------------------------]]--

local cfg_folder = "openai"
function OpenAI.FileReset()

    local cfg_file = cfg_folder .. "/openai_config.txt"

    if not file.Exists(cfg_folder, "DATA") then
        file.CreateDir(cfg_folder)
    end

    if file.Exists(cfg_file, "DATA") then
        file.Delete(cfg_file)
    end

    file.Write(cfg_file, OpenAI.default_cfg)

end
concommand.Add("openai_config_resetall", OpenAI.FileReset, _, "Reset to default config")



function OpenAI.FileRead()
    local cfg = {}
    local cfg_file = file.Open(cfg_folder .. "/openai_config.txt", "r", "DATA")

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



do
    if not file.Exists("openai/openai_config.txt", "DATA") then
        OpenAI.FileReset()
    end
end
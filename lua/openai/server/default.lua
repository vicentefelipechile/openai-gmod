--[[----------------------------------------------------------------------------
                                Default configuration
----------------------------------------------------------------------------]]--

--[[------------------------
        Configuration
------------------------]]--

OpenAI.default = OpenAI.default or {
    user = "[steamid]",

    image_size = "256x256",

    chat_model = "gpt-3.5-turbo",
    chat_temperature = 1,
    chat_max_tokens = 24,

    translator_model = "gpt-3.5-turbo",
    translator_temperature = 1,
    translator_max_tokens = 24,
    translator_cmd = ",",

    discord_avatar = "https://i.imgur.com/wmTcTkk.png",
    discord_name = "OpenAI"
}

OpenAI.default_cfg = OpenAI.default_cfg or [[
# API Token
OpenAI: sk-XXXXXXXXXXXXXXXXXXXXX
User: [steamid]

# Images configuracion
Image_size: 256x256


# Chat configuracion
Chat_model: gpt-3.5-turbo
Chat_temperature: 1
Chat_max_tokens: 24

# Translator configuracion
Translator_model: gpt-3.5-turbo
Translator_temperature: 1
Translator_max_tokens: 24
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
#
# Revisa mas aqui V
# https://platform.openai.com/docs/models/model-endpoint-compatibility
]]



--[[------------------------
        Main Scripts
------------------------]]--

local folder = "openai"
function OpenAI.FileReset()

    local cfg_file = folder .. "/openai_config.txt"

    if not file.Exists(folder, "DATA") then
        file.CreateDir(folder)
    end

    if file.Exists(cfg_file, "DATA") then
        file.Delete(cfg_file)
    end

    file.Write(cfg_file, OpenAI.default_cfg)

end
concommand.Add("openai_config_resetall", OpenAI.FileReset, _, "Reset to default config")


if not file.Exists("openai/openai_config.txt", "DATA") then
    OpenAI.FileReset()
end
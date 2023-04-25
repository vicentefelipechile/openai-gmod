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
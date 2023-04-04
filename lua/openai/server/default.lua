OpenAI.default = OpenAI.default or {

    completion_model = "text-davinci-003",
    completion_suffix = nil,
    completion_max_tokens = 24,
    completion_temperature = 1,
    completion_user = "STEAM_[steamid]",

    image_size = "256x256",
    image_user = "STEAM_[steamid]",

    chat_model = "gpt-3.5-turbo",
    chat_message = "[{\"role\": \"user\", \"content\": \"[first_message]\"}]",
    chat_temperature = 1,
    chat_max_tokens = 24,
    chat_user = "STEAM_[steamid]",
}
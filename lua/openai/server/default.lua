OpenAI.default = OpenAI.default or {}
OpenAI.default.chat = {}
OpenAI.default.image = {}
OpenAI.default.completions = {}

local defaultCompletions = {
    model = "text-davinci-003",
    suffix = nil,
    max_tokens = 24,
    temperature = 1,
    user = "STEAM_[steamid]",
}

local defaultImages = {
    size = "256x256",
    user = "STEAM_[steamid]",
}

local defaultChat = {
    model = "gpt-3.5-turbo",
    message = "[{\"role\": \"user\", \"content\": \"[first_message]\"}]",
    temperature = 1,
    max_tokens = 24,
    user = "STEAM_[steamid]",
}

OpenAI.default.completions = defaultCompletions
OpenAI.default.image = defaultImages
OpenAI.default.chat = defaultChat
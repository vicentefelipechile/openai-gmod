--[[----------------------------------------------------------------------------
                                Shared OpenAI
----------------------------------------------------------------------------]]--
OpenAI.Commands = OpenAI.Commands or {}

CreateConVar("openai_admin", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "What type of admin we should to use? (1: All-Users, 2: Only Admin, 3: Only SuperAdmin, 4: ULX)")
CreateConVar("openai_displayerrorcl", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Display error to client?", 0, 1)


--[[----------------------------
        Include Files
----------------------------]]--
if SERVER then
    AddCSLuaFile("openai/modules/enum_color.lua")
    AddCSLuaFile("openai/modules/httpcode.lua")
    include("openai/server/default.lua")
    include("openai/server/binarymodule.lua")

    AddCSLuaFile("openai/modules/chat.lua")
    AddCSLuaFile("openai/modules/dalle.lua")
    AddCSLuaFile("openai/modules/discord.lua")
end
include("openai/modules/enum_color.lua")
include("openai/modules/httpcode.lua")


--[[----------------------------
        Shared Functions
----------------------------]]--
function OpenAI.print(...)
    local color = SERVER and COLOR_SERVER or COLOR_CLIENT

    MsgC(color, unpack({...}), "\n")
end


function OpenAI.handleCommands(str)
    local command, value = str:match("^(%S+)%s+(.*)$")

    if command and command:sub(1,1) == "!" then
        command = command:sub(2)
    else
        return nil
    end

    return command, value
end


local cfg_folder = "openai"
function OpenAI.FileReset()

    local cfg_file = cfg_folder .. "/openai_config.txt"

    if not file.Exists(cfg_folder, "DATA") then
        file.CreateDir(cfg_folder)
    end

    if file.Exists(cfg_file, "DATA") then
        file.Delete(cfg_file)
    end

    local default = [[
# API Token
OpenAI: sk-XXXXXXXXXXXXXXXXXXXXX¿


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

    file.Write(cfg_file, default)

end

if SERVER then
    concommand.Add("openai_config_resetall", OpenAI.FileReset, _, "Reset to default config")

    if not file.Exists(cfg_folder .. "/openai_config.txt", "DATA") then
        OpenAI.FileReset()
    end
end



local trim = string.Trim
local start = string.StartsWith

if SERVER then
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
end

do
    if not file.Exists("openai/openai_config.txt", "DATA") then
        OpenAI.FileReset()
    end
end


--[[----------------------------
        Post-Include Files
----------------------------]]--
include("openai/modules/chat.lua")
include("openai/modules/dalle.lua")
include("openai/modules/discord.lua")
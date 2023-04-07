--[[----------------------------------------------------------------------------
                                Discord Module
----------------------------------------------------------------------------]]--

local defaultinfo = CreateConVar("openai_discord_usedefaultwebhookinfo", 0, FCVAR_ARCHIVE, "Use the default info from Discord instead of replace it", 0, 1)
local usediscord = CreateConVar("openai_discord_enable", 0, FCVAR_ARCHIVE, "Enable the discord webhook", 0, 1)

--[[------------------------
      Local Definitions
------------------------]]--

local function getDate()
    return os.date("%Y-%m-%dT%X.000Z")
end

local cfg = OpenAI.FileRead()


--[[------------------------
        Main Scripts
------------------------]]--

function OpenAI.discordSendMessage(tbl)
    if not type(tbl) == "table" then MsgC(c_error, "ERROR", c_normal, ": The argument #1 isn't a table") return end

    reqwest({
        method = "POST",
        url = cfg["discord_webhook"],
        timeout = 20,

        body = util.JSONToTable(tbl),
        type = "application/json",

        headers = {
            ["User-Agent"] = "OpenAI/1.0 (" .. (system.IsLinux() and "Linux" or system.IsWindows() and "Windows" or "OSX") .. ") User-Agent"
        }

        success = function(code, _, headers)
            local fCode = OpenAI.HTTPcode[code] or function() MsgC(code) end
            fCode()
        end,
        failed = function(err)
            MsgC(err, "\n")
        end
    })


end


--[[------------------------
        Chat Fetch
------------------------]]--

hook.Add("OpenAI.chatFetch", "OpenAI.discord_chat", function(ply, prompt, response)

    local body = {
        content = nil,
        embeds = {
            {
                description = string.format( [[```[%s]: %s\n[%s]: %s```]], ply:Nick(), prompt, cfg["discord_name"], response )
                color = 5814783,
                timestamp = getDate()
            }
        },
        username = cfg["discord_name"],
        avatar_url = cfg["discord_avatar"]
    }

    if GetConVar("openai_discord_usedefaultwebhookinfo"):GetBool() then
        body["username"] = cfg["discord_name"]
        body["avatar_url"] = cfg["discord_avatar"]
    end

    OpenAI.discordSendMessage(body)
end)


--[[------------------------
        Image Fetch
------------------------]]--

hook.Add("OpenAI.imageFetch", "OpenAI.discord_image", function(ply, prompt, response)

    local body = {
        content = nil,
        embeds = {
            {
                description = string.format( [[```[%s]: %s\n[%s]: %s```]], ply:Nick(), prompt, cfg["discord_name"] )
                color = 5814783,
                timestamp = getDate(),
                image = {
                    url = response
                }
            }
        },
        username = cfg["discord_name"],
        avatar_url = cfg["discord_avatar"]
    }

    if defaultinfo:GetBool() then
        body["username"] = cfg["discord_name"]
        body["avatar_url"] = cfg["discord_avatar"]
    end

    OpenAI.discordSendMessage(body)
end)
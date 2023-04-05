local function getDate()
    return os.date("%Y-%m-%dT%X.000Z")
end

local cfg = OpenAI.FileRead()

function OpenAI.discordSendMessage(tbl)
    if not type(tbl) == "table" then return end
    if not cfg["discord_webhook"] or 
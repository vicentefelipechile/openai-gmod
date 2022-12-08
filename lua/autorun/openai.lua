--[[---------------------------------------------------------
    OpenAI Main Settings
-----------------------------------------------------------]]
openai = {
    url = "https://api.openai.com/v1/",

    blacklist = {
        ["STEAM_0:0:619402913"] = true,
    },
}

if SERVER then
    util.AddNetworkString("OpenAI.CLtoSV")
    util.AddNetworkString("OpenAI.SVtoCL")
end

--[[---------------------------------------------------------
    OpenAI HTTP Module
-----------------------------------------------------------]]
function openai.print(str, color, breakline, noPrefix, debug)

    if debug and not GetConVar("openai_debug"):GetBool() then return end

    if not IsColor(color) then
        color = Color(123, 250, 250)
    end

    local n = "\n"

    local prefix = "[OpenAI] "

    if breakline then
        n = ""
    end

    if noPrefix then
        prefix = ""
    end

    MsgC(Color(255, 255, 255), prefix, color, tostring(str) .. n)
end

function openai.code(code)
    return code == 200 and openai.print("Success to access - 200") or openai.print(code)
end

function openai.table(tbl, debug)

    if debug and not GetConVar("openai_debug"):GetBool() then return end

    if not istable(tbl) then return openai.print(tbl) end

    for k, v in pairs(tbl) do
        openai.print(" - " .. k, _, true) openai.print(": \t" .. v, Color(82, 189, 189), _, true)
    end
end

function openai.TTJ(tbl)
    if not istable(tbl) then return end

    local json = "{"

    for k, v in pairs(tbl) do
        if isnumber(v) then
            json = json .. "\"" .. k .. "\":" .. v .. ","
        else
            json = json .. "\"" .. k .. "\":\"" .. v .. "\","
        end
    end
    
    json = string.sub(json, 0, -2) .. "}"

    return json
end

CreateConVar("openai_debug", 0, FCVAR_ARCHIVE, "Turn on or off debugging of the OpenAI Functions", 0, 1)

CreateConVar("openai_cooldown_text",  5, {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Cooldown to use Text Completion", 1, 300)
CreateConVar("openai_cooldown_image", 5, {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Cooldown to use Image Generator", 1, 300)
CreateConVar("openai_gdr", 1, {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Turn on or off to send GDR Messages", 0, 1)
CreateConVar("openai_everyone", 1, {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Everyone can use the OpenAI Functions", 0, 1)
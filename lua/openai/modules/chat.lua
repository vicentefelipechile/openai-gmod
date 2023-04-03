if SERVER then
    util.AddNetworkString("openai.chatCLtoSV")
    util.AddNetworkString("openai.chatSVtoCL")
end


local cfg = OpenAI.FileRead()
local API = cfg["openai"] or false

local header = API and {
    ["Authorization"] = "Bearer " .. API,
}

local c_error = COLOR_RED
local c_normal = COLOR_SERVER

local function replaceSteamID(text, ply)
    if string.find(text, "%[steamid%]") then
      text = string.gsub(text, "%[steamid%]", ply:SteamID())
    end
  
    if string.find(text, "%[steamid64%]") then
      text = string.gsub(text, "%[steamid64%]", ply:SteamID64())
    end
  
    return text
  end
  

function OpenAI.chatFetch(ply, msg)
    if not API then return end

    local body = {
        model       = cfg["chat_model"],
        messages    = string.gsub(cfg["message"], "%[first_message%]", msg),
        temperature = cfg["chat_temperature"],
        max_tokens  = cfg["chat_max_tokens"],
        user        = replaceSteamID( cfg["chat_user"], ply ),
    }

    OpenAI.HTTP("chat", body, header, function(code, body)
        local fCode = OpenAI.HTTPcode[code] or function() OpenAI.print(code) end
        fCode()

        if code == 200 then
            json = util.JSONToTable( string.Trim( body ) )
        end
    end,
    function(err)
        OpenAI.print(c_error, err)
    end
)

end
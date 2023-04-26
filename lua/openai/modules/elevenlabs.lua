--[[----------------------------------------------------------------------------
                                Elevenlabs Module
----------------------------------------------------------------------------]]--


if SERVER then
      util.AddNetworkString("OpenAI.elevenlabsToCL")

      
else

      return
end

--[[------------------------
      Local Definitions
------------------------]]--

local voice = "TxGEqnHWrfWFTfGW9XjX"
OpenAI.REQUESTS["elevenlabs"] = { "POST", "https://api.elevenlabs.io/v1/text-to-speech/" .. voice }

if not file.Exists("openai/elevenlabs", "DATA") then
      file.CreateDir("openai/elevenlabs")
end


--[[------------------------
        Main Scripts
------------------------]]--


function OpenAI.ElevenlabsTTS(ply, msg)
      local API = OpenAI.GetConfig("elevenlabs")

      if not API then return end

      local canUse = hook.Call("OpenAI.ElevenlabsTTT.CanUse", ply)
      if canUse == false then return end

      local headers = {
            ["Accept"] = "audio/mpeg",
            ["Content-Type"] = "application/json",
            ["xi-api-key"] = API
      }

      local request = OpenAI.Request()
      request:SetType("elevenlabs")
      request:SetHeaders(headers)
      request:AddBody("text", msg)

      request:SetSuccess(function(code, body, header)
            OpenAI.HandleCode(code)
            
            file.Write( OpenAI.SetFileName("voice", "mp3", "elevenlabs"), body )
      end)

      request:SendRequest()
end
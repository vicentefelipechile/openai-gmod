--[[----------------------------------------------------------------------------
                                Elevenlabs Module
----------------------------------------------------------------------------]]--

local enabled = CreateConVar("openai_elevenlabs_enabled", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Toggle the elevenlabs module", 0, 1)
local enabled = CreateConVar("openai_elevenlabs_enabled", 1, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Volume of the voice from elevenlabs module", 0, 5)

if not file.Exists("openai/elevenlabs", "DATA") then
      file.CreateDir("openai/elevenlabs")
end


--[[------------------------
      Shared Definitions
------------------------]]--

if SERVER then
      util.AddNetworkString("OpenAI.elevenlabsToCL")
else
      CreateClientConVar("openai_elevenlabs_voice", "josh", true, true, "What voice response the elevenlabs module?")
      local download = CreateConVar("openai_elevenlabs_download", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE}, "Set on to download al sound files from elevenlabs module", 0, 1)

      net.Receive("OpenAI.elevenlabsToCL", function()
            if not download:GetBool() then return end

            local ply = net.ReadEntity()
            local prompt = net.ReadString()
            local history = net.ReadString()
            local token = net.ReadString()

            local url = string.format("https://api.elevenlabs.io/v1/history/%s/audio", history)

            HTTP({
                  method = "GET",
                  url = url,
                  headers = {
                        ["xi-api-key"] = token
                  },
                  body = util.TableToJSON({}),
                  type = "application/json",
                  success = function(code, body)
                        OpenAI.HandleCode(code)

                        if code == 200 then
                              local path = OpenAI.SetFileName("voice", ".mp3", "elevenlabs")
                              file.Write( path, body )

                              sound.PlayFile("data/" .. path, "3d noplay", function(station, errCode, errStr)
                                    if IsValid(station) then
                                          local who = IsValid(ply) and ply or LocalPlayer()
                                          station:SetPos( who:GetPos() )
                                          station:SetVolume(1)
                                          station:Play()

                                          local id = os.time() .. "_voice"
                                          hook.Add("Think", id, function()
                                                if station:GetState() == GMOD_CHANNEL_STOPPED then
                                                      hook.Remove("Think", id)
                                                end

                                                station:SetPos( who:GetPos() )
                                          end)
                                    end
                              end)

                              hook.Call("OpenAI.Elevenlabs.OnGetFile", ply, path)
                        end
                  end,
                  failed = function() end
            })

      end)

      return
end



--[[------------------------
      Local Definitions
------------------------]]--

local voices = {
      ["rachel"]  = "21m00Tcm4TlvDq8ikWAM",
      ["doni"]    = "AZnzlk1XvdvUeBnXmlld",
      ["bella"]   = "EXAVITQu4vr4xnSDxMaL",
      ["antoni"]  = "ErXwobaYiN019PkySvjV",
      ["elli"]    = "MF3mGyEYCl7XYWbV9V6O",
      ["josh"]    = "TxGEqnHWrfWFTfGW9XjX",
      ["arnold"]  = "VR6AewLTigWG4xSOukaG",
      ["adam"]    = "pNInz6obpgDQGcFmaJgB",
      ["sam"]     = "yoZ06aMxZJJ28mfd3POQ",
}

OpenAI.REQUESTS["elevenlabs"] = { "POST", "https://api.elevenlabs.io/v1/text-to-speech/" }
OpenAI.REQUESTS["elevenlabs.history"] = { "GET", "https://api.elevenlabs.io/v1/history" }



--[[------------------------
        Main Scripts
------------------------]]--

function OpenAI.ElevenlabsTTS(ply, msg)
      if not enabled:GetBool() then return end

      local voice = ply:GetInfo("openai_elevenlabs_voice")

      local API = OpenAI.GetConfig("elevenlabs")
      local url = string.format([[https://api.elevenlabs.io/v1/text-to-speech/%s]], voices[ string.lower( voice:GetString() ) ] or voices["josh"] )

      local headers = {
            ["Accept"] = "audio/mpeg",
            ["Content-Type"] = "application/json",
            ["xi-api-key"] = API
      }

      HTTP({
            url         = url,
            method      = "POST",
            body        = util.TableToJSON({ text = msg }),
            headers     = headers,
            type        = "application/json",
            success     = function(code, body, header)
                  OpenAI.HandleCode(code)
                  
                  HTTP({
                        url         = OpenAI.REQUESTS["elevenlabs.history"][2],
                        method      = OpenAI.REQUESTS["elevenlabs.history"][1],
                        headers     = { ["xi-api-key"] = API },
                        body        = util.TableToJSON({}),
                        success     = function(code, body)
                              OpenAI.HandleCode(code)
            
                              local json = util.JSONToTable(body)
                              if code == 200 then
                                    local history = json["history"][1]["history_item_id"]
            
                                    net.Start("OpenAI.elevenlabsToCL")
                                          net.WriteEntity(ply)
                                          net.WriteString(msg)
                                          net.WriteString(history)
                                          net.WriteString(API)
                                    net.Send()
                              elseif code >= 400 then
                                    local mError = json["detail"]["message"]
                                    MsgC(COLOR_WHITE, "[", COLOR_CYAN, "Elevenlabs", COLOR_WHITE, "] ", COLOR_RED, mError, "\n")
                              end
                        end,
                        failed      = function() end
                  })
            end,
            failed      = function() end
      })
end
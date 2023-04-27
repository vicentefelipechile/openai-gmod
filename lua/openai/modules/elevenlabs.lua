--[[----------------------------------------------------------------------------
                                Elevenlabs Module
----------------------------------------------------------------------------]]--

local enabled = CreateConVar("openai_elevenlabs_enabled", 0, {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Toggle the elevenlabs module", 0, 1)

if not file.Exists("openai/elevenlabs", "DATA") then
      file.CreateDir("openai/elevenlabs")
end



--[[------------------------
      Shared Definitions
------------------------]]--

if SERVER then
      util.AddNetworkString("OpenAI.elevenlabsToCL")
else
      CreateConVar("openai_elevenlabs_download", 1, {FCVAR_USERINFO, FCVAR_ARCHIVE}, "Set on to download al sound files from elevenlabs module", 0, 1)

      net.Receive("OpenAI.elevenlabsToCL", function()
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
                                          station:SetParent( who )
                                          station:SetVolume(4)
                                          station:Play()
                                    end
                              end)
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

local voice = "TxGEqnHWrfWFTfGW9XjX"
OpenAI.REQUESTS["elevenlabs"] = { "POST", "https://api.elevenlabs.io/v1/text-to-speech/" .. voice }
OpenAI.REQUESTS["elevenlabs.history"] = { "GET", "https://api.elevenlabs.io/v1/history" }


local function GetPlayersToSend()
      local tbl = {}
  
      for _, ply in ipairs( player.GetAll() ) do
          if ply:GetInfoNum("openai_elevenlabs_download", 0) == 1 then
              table.insert(tbl, ply)
          end
      end
  
      return tbl
end



--[[------------------------
        Main Scripts
------------------------]]--

function OpenAI.ElevenlabsTTS(ply, msg)

      local API = OpenAI.GetConfig("elevenlabs")

      local headers = {
            ["Accept"] = "audio/mpeg",
            ["Content-Type"] = "application/json",
            ["xi-api-key"] = API
      }

      HTTP({
            url         = OpenAI.REQUESTS["elevenlabs"][2],
            method      = OpenAI.REQUESTS["elevenlabs"][1],
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
                                          net.WriteVector(ply:GetPos())
                                    net.Broadcast()
                              end
                        end,
                        failed      = function() end
                  })
            end,
            failed      = function() end
      })
end
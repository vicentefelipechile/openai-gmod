--[[------------------------
      Local Definitions
------------------------]]--

local c_ok = COLOR_GREEN
local c_error = COLOR_RED
local c_normal = COLOR_SERVER
local c_important = COLOR_MENU

local reqwesturl = "https://github.com/WilliamVenner/gmsv_reqwest/releases/tag/v3.0.2/"
local cfg_folder = "openai"


--[[------------------------
        Server Scripts
------------------------]]--
function OpenAI.BinaryModule(message)
    message = message or true

    if util.IsBinaryModuleInstalled("reqwest") then
        require("reqwest")
        return true
    end

    local version = "gmsv_reqwest_"

    if system.IsWindows() then
        version = version .. "win"
        version = jit.arch == "x64" and "64.dll" or "32.dll"
    elseif system.IsLinux() then
        version = version .. "linux"
        version = jit.arch == "x64" and "64.dll" or ".dll"
    else
        version = "Unsupported"
    end

    if message then
        OpenAI.print(c_error, "ERROR", c_normal, ": You don't have '", c_important, "reqwest", c_normal, "' module installed")
        OpenAI.print("Get one in this page:")
        OpenAI.print(c_important, "https://github.com/WilliamVenner/gmsv_reqwest/releases")
        OpenAI.print("And download this file for your server: ", c_important, version)
        OpenAI.print("Or just run this command ", c_important, "openai_downloadmodule", c_normal, "to get the file")
    end

    return version
end


function OpenAI.DownloadBinaryModule()
    if util.IsBinaryModuleInstalled("reqwest") then require("reqwest") return end

    local bin_file = OpenAI.BinaryModule(false)

    if not file.Exists(cfg_folder) then
        file.CreateDir(cfg_folder)
    end

    HTTP({
        method = "GET",
        url = reqwesturl .. bin_file,

        success = function(code, bin)
            local fCode = OpenAI.HTTPcode[code] or function() OpenAI.print(code) end
            fCode()

            if code == 200 then
                file.Write(cfg_folder .. "/" .. bin_file .. ".dat", bin)
            end
        end,

        failed = function(msg)
            OpenAI.print("Error al descargar el archivo:")
            OpenAI.print(msg)
        end
    })
end
concommand.Add("openai_downloadmodule", OpenAI.DownloadBinaryModule, nil, "Download the module")


OpenAI.BinaryModule()
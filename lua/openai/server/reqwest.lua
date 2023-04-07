--[[----------------------------------------------------------------------------
                                Reqwest Module
----------------------------------------------------------------------------]]--


--[[------------------------
      Local Definitions
------------------------]]--

local N = "\n"

local reqwesturl = "https://github.com/WilliamVenner/gmsv_reqwest/releases/download/v3.0.2/"
local folder = "openai"


--[[------------------------
        Server Scripts
------------------------]]--
function OpenAI.BinaryModule(message)
    message = message == nil and true or false

    if util.IsBinaryModuleInstalled("reqwest") then
        require("reqwest")
        return true
    end

    local version = "gmsv_reqwest_"

    if system.IsWindows() then
        version = version .. "win"
        version = jit.arch == "x64" and version .. "64.dll" or version .. "32.dll"
    elseif system.IsLinux() then
        version = version .. "linux"
        version = jit.arch == "x64" and version .. "64.dll" or version .. ".dll"
    else
        version = "Unsupported"
    end

    if message then
        MsgC(COLOR_WHITE, " ================ ", COLOR_CYAN, "OpenAI", COLOR_WHITE, " ================ ", N)
        MsgC(COLOR_RED, "ERROR", COLOR_SERVER, ": You don't have '", COLOR_MENU, "reqwest", COLOR_SERVER, "' module installed", N)
        MsgC("Get one in this page:", N)
        MsgC(COLOR_MENU, "https://github.com/WilliamVenner/gmsv_reqwest/releases", N)
        MsgC("And download this file for your server: ", COLOR_MENU, version, N)
        MsgC("Or just run this command ", COLOR_MENU, "openai_downloadmodule", COLOR_SERVER, " to get the file", N)
        MsgC(COLOR_WHITE, " ================ ", COLOR_CYAN, "OpenAI", COLOR_WHITE, " ================ ", N)
    end

    return version
end


function OpenAI.DownloadBinaryModule()
    if util.IsBinaryModuleInstalled("reqwest") then require("reqwest") return end

    local bin_file = OpenAI.BinaryModule(false)

    if not file.Exists(folder, "DATA") then
        file.CreateDir(folder)
    end

    HTTP({
        method = "GET",
        url = reqwesturl .. bin_file,

        success = function(code, bin)
            local fCode = OpenAI.HTTPcode[code] or function() MsgC(code) end
            fCode()

            if code == 200 then
                file.Write(folder .. "/" .. bin_file .. ".dat", bin)
            end
        end,

        failed = function(msg)
            MsgC("Error al descargar el archivo:")
            MsgC(msg)
        end
    })
end
concommand.Add("openai_downloadmodule", function() OpenAI.DownloadBinaryModule(false) end, nil, "Download the module")


OpenAI.BinaryModule()
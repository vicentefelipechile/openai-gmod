--[[----------------------------------------------------------------------------
                                Server-side OpenAI
----------------------------------------------------------------------------]]--

local REQUESTS = {
    ["Models"] = true,          -- https://platform.openai.com/docs/api-reference/models
    ["Completions"] = true,     -- https://platform.openai.com/docs/api-reference/completions
    ["Chat"] = true,            -- https://platform.openai.com/docs/api-reference/chat
    ["Images"] = true,          -- https://platform.openai.com/docs/api-reference/images
}

local c_error = COLOR_RED
local c_normal = COLOR_WHITE
local c_important = COLOR_MENU

local reqwesturl = "https://github.com/WilliamVenner/gmsv_reqwest/releases/tag/v3.0.2/"



function OpenAI.HTTP()
    
end


function OpenAI.BinaryModule(message)

    if util.IsBinaryModuleInstalled("reqwest") then
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

    if not message then
        OpenAI.print(c_error, "ERROR", c_normal, ": You don't have '", c_important, "reqwest", c_normal, "' module installed")
        OpenAI.print("Get one in this page:")
        OpenAI.print(c_important, "https://github.com/WilliamVenner/gmsv_reqwest/releases")
    end

    return false
end


function OpenAI.DownloadBinaryModule()

end
concommand.Add("openai_downloadmodule", OpenAI.DownloadBinaryModule, nil, "Download the module")


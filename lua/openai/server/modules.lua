--[[----------------------------------------------------------------------------
                                Modules Module
----------------------------------------------------------------------------]]--

local REQUESTS = OpenAI.REQUESTS

--[[------------------------
        Module Class
------------------------]]--

local openai = {

    request = {
        url = "https://api.openai.com",
        body = {},
        method = "GET",
        headers = nil,
        type = "application/json",
        timeout = 25,
        success = function() end,
        failed = function() MsgC(COLOR_RED, err, "\n") end,
    },

    SetType = function(self, type)
        if not REQUESTS[type] then
            error( "bad argument #1 to 'openai:SetType' (you '" .. tostring(type) .. "' has not been found in the OpenAI.REQUEST table)" )
        end

        local method, url = REQUESTS[type][1], REQUESTS[type][2]
        self.request["method"] = method
        self.request["url"] = url
    end,

    GetType = function(self)
        return self.request["method"], self.request["url"]
    end,

    SetBody = function(self, body)
        if not body == nil and #body == 0 then
            error( "bad argument #1 to 'openai:SetBody' (string expected, got " .. type( body ) .. ")" )
        end

        self.request["body"] = body
    end,

    AddBody = function(self, key, value)
        self.request["body"][key] = value
    end,

    GetBody = function(self)
        return self.request["body"]
    end,

    SetHeaders = function(self, header)
        self.request["headers"] = header
    end,

    GetHeaders = function(self)
        return self.request["headers"]
    end,

    SetSuccess = function(self, func)
        if not isfunction(func) then
            error( "bad argument #1 to 'openai:SetSuccess' (function expected, got " .. type( body ) .. ")" )
        end

        self.request["success"] = func
    end,

    SetFailed = function(self, func)
        if not isfunction(func) then
            error( "bad argument #1 to 'openai:SetFailed' (function expected, got " .. type( body ) .. ")" )
        end

        self.request["failed"] = func
    end,

    GetAll = function(self)
        local all = table.Copy(self.request)
        if all["headers"] and all["headers"]["Authorization"] then
            all["headers"]["Authorization"] = "***PROTECTED***"
        end

        return all
    end,

    SendRequest = function(self)
        local req = table.Copy( self.request )
        if req["body"]["user"] then
            req["body"]["user"] = OpenAI.ReplaceSteamID(OpenAI.GetConfig("user"), req["body"]["user"])
        end

        local body = util.TableToJSON(req["body"])
        
        if req["body"]["max_tokens"] then
            body = OpenAI.IntToJson( "max_tokens", body )
        end

        req["headers"] = req["headers"] or OpenAI.GetAPI()

        req["body"] = body

        HTTP(req)
    end
}
openai.__index = openai


function OpenAI.Request()
    local fallback = table.Copy(openai)
    return setmetatable( { [ 0 ] = 0 }, fallback)
end


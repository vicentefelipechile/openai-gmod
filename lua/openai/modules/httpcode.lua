--[[----------------------------------------------------------------------------
                                HTTP Message Errors
----------------------------------------------------------------------------]]--

local function pMsg(msg)
    MsgC(COLOR_SERVER, " : ", msg, "\n")
end

local function pError(msg)
    MsgC(COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] ", COLOR_RED, msg)
end

local function pOk(msg)
    MsgC(COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] ", COLOR_GREEN, msg)
end


OpenAI.HTTPcode = {
    [200] = function() pOk("200 - OK") pMsg("The resource has been obtained") end,
    [201] = function() pOk("201 - Created") pMsg("The request succeeded, and a new resource was created as a result") end,
    [202] = function() pOk("202 - Accepted") pMsg("The request has been received but not yet acted upon") end,
    [203] = function() pOk("203 - Non-Authoritative Information") pMsg("This response code means the returned metadata is not exactly the same as is available from the origin server") end,
    [204] = function() pOk("204 - No Content") pMsg("There is no content to send for this request, but the headers may be useful") end,
    

    [400] = function() pError("400 - Bad Request") pMsg("The server was unable to interpret the request given invalid syntax") end,
    [401] = function() pError("401 - Unauthorized") pMsg("Authentication is required to get the requested response") end,
    [403] = function() pError("403 - Forbidden") pMsg("You don't have the necessary permissions for certain content, so the server is refusing to grant an appropriate response") end,
    [404] = function() pError("404 - Not Found") pMsg("The server was unable to find the requested content") end,
    [405] = function() pError("405 - Method Not Allowed") pMsg("The requested method is known to the server but it has been disabled and cannot be used") end,
    [408] = function() pError("408 - Request Timeout") pMsg("A timeout has occurred while processing an HTTP request") end,
    [409] = function() pError("409 - Conflict") pMsg("The server encountered a conflict with the request sent with the current state of the server") end,
    [410] = function() pError("410 - Gone") pMsg("The requested content has been deleted from the server") end,
    [411] = function() pError("411 - Length Required") pMsg("The server rejected the request because the Content-Length is not defined") end,
    [429] = function() pError("429 - Too Many Requests") pMsg("The user has sent too many requests") end,
}

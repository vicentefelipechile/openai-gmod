--[[----------------------------------------------------------------------------
                                HTTP Message Errors
----------------------------------------------------------------------------]]--

local function pMsg(msg)
    MsgC(COLOR_SERVER, " : ", msg, "\n")
end

local function eMsg(msg)
    MsgC(COLOR_SERVER, " > ", msg, "\n")
end

local function pError(p, msg)
    MsgC( COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] " )
    MsgC( SERVER and COLOR_SERVER or COLOR_CLIENT, SERVER and "SV " or "CL " )
    MsgC( COLOR_WHITE, p, "\n > ", COLOR_RED, msg)
end

local function pOk(p, msg)
    MsgC(COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] ", SERVER and unpack({COLOR_SERVER, "SV"}) or unpack({COLOR_CLIENT, "SV"}), COLOR_WHITE, p, "\n > ", COLOR_GREEN, msg)
end


OpenAI.HTTPcode = {

    --[[--------------------
          Succesful 2XX
    --------------------]]--
    [200] = function(p) pOk(p, "200 - OK") pMsg("The resource has been obtained") end,
    [201] = function(p) pOk(p, "201 - Created") pMsg("The request succeeded, and a new resource was created as a result") end,
    [202] = function(p) pOk(p, "202 - Accepted") pMsg("The request has been received but not yet acted upon") end,
    [203] = function(p) pOk(p, "203 - Non-Authoritative Information") pMsg("This response code means the returned metadata is not exactly the same as is available from the origin server") end,
    [204] = function(p) pOk(p, "204 - No Content") pMsg("The request has been send with no errors also there is no content to send for this request, but the headers may be useful") end,
    [205] = function(p) pOk(p, "205 - Reset Content")  pMsg("This response tells the client to reset the document view, so for example to clear the content of a form, reset a canvas state, or to refresh the UI") end,
    [206] = function(p) pOk(p, "206 - Partial Content")  pMsg("The request has succeeded and the body contains the requested ranges of data, as described in the Range header of the request") end,
    [207] = function(p) pOk(p, "207 - Multi-Status")  pMsg("This response code indicates that there might be a mixture of responses") end,
    [208] = function(p) pOk(p, "208 - Already Reported")  pMsg("This response code is used in a 207 (207 Multi-Status) response to save space and avoid conflicts") end,


    --[[--------------------
        Client Error 4XX
    --------------------]]--
    [400] = function(p) pError(p, "400 - Bad Request") pMsg("The server was unable to interpret the request given invalid syntax") end,
    [401] = function(p)
        pError(p, "401 - Unauthorized") pMsg("Authentication is required to get the requested response")
        eMsg("Look at this page for more info: https://platform.openai.com/docs/guides/error-codes/error-codes")
    end,
    [403] = function(p) pError(p, "403 - Forbidden") pMsg("You don't have the necessary permissions for certain content, so the server is refusing to grant an appropriate response") end,
    [404] = function(p) pError(p, "404 - Not Found") pMsg("The server was unable to find the requested content") end,
    [405] = function(p) pError(p, "405 - Method Not Allowed") pMsg("The requested method is known to the server but it has been disabled and cannot be used") end,
    [408] = function(p) pError(p, "408 - Request Timeout") pMsg("A timeout has occurred while processing an HTTP request") end,
    [409] = function(p) pError(p, "409 - Conflict") pMsg("The server encountered a conflict with the request sent with the current state of the server") end,
    [410] = function(p) pError(p, "410 - Gone") pMsg("The requested content has been deleted from the server") end,
    [411] = function(p) pError(p, "411 - Length Required") pMsg("The server rejected the request because the Content-Length is not defined") end,
    [429] = function(p)
        pError(p, "429 - Rate limit reached for requests") pMsg("This error message indicates that you have hit your assigned rate limit for the API")
        eMsg("Look at this page for more info: https://help.openai.com/en/articles/6891829-error-code-429-rate-limit-reached-for-requests")
    end,


    --[[--------------------
        Server Error 5XX
    --------------------]]--
    [500] = function(p) pError(p, "500 - Internal Server Error") pMsg("This server error response code indicates that the server encountered an unexpected condition that prevented it from fulfilling the request")
        eMsg("Look at this page for more info: https://platform.openai.com/docs/guides/error-codes/error-codes")
        eMsg("Generally you can assume it wasn't your fault")
    end,
    [501] = function(p) pError(p, "501 - Not Implemented") pMsg("This server error response code means that the server does not support the functionality required to fulfill the request") end,
    [502] = function(p) pError(p, "502 - Bad Gateway") pMsg("This server error response code indicates that the server, while acting as a gateway or proxy, received an invalid response from the upstream server") end,
    [503] = function(p) pError(p, "503 - Service Unavailable") pMsg("This server error response code indicates that the server is not ready to handle the request") end,
    [504] = function(p) pError(p, "504 - Gateway Timeout") pMsg("This server error response code indicates that the server, while acting as a gateway or proxy, did not get a response in time from the upstream server that it needed in order to complete the request") eMsg("This error is usually not something you can fix") end,
    [505] = function(p) pError(p, "505 - HTTP Version Not Supported") pMsg("This response status code indicates that the HTTP version used in the request is not supported by the server") end,
    [507] = function(p) pError(p, "507 - Insufficient Storage") pMsg("This operation couldn't succeed, maybe because the request it's too large to fit on a disk") end,
    [508] = function(p) pError(p, "508 - Loop Detected") pMsg("It indicates that the server terminated an operation because it encountered an infinite loop while processing a request with \"Depth: infinity\"") eMsg("This status indicates that the entire operation failed") end,
}

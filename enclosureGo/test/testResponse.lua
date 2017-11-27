local response = require ('enclosure.response.Response'):new()
local request = require ('enclosure.request.Request'):new()

response:send(true, request:getArgs())

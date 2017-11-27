local request = require ('enclosure.request.Request'):new()

local json = require "cjson"


local args = request:getArgs()
local result = json.encode(args)
--ngx.log(ngx.ERR, 'city:'..args.person.location[1].city)
--ngx.log(ngx.ERR, 'province:'..args.person.location[2].province)
--ngx.log(ngx.ERR, 'name:'..args.person.name)
--ngx.log(ngx.ERR, 'a:'..args.a)
ngx.say(result)

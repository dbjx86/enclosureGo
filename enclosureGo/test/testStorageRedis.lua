local redis = require ('enclosure.memory.redis'):new()
local cjson = require ('cjson')

function set()
	local arg = ngx.req.get_uri_args()
	for k, v in pairs(arg) do
		if redis:setStorage(k, v) == fasle then
			ngx.say("set storage fail!")
		end
	ngx.say('ok')
	end
end

function get()
	local arg = ngx.req.get_uri_args()
	local str = {}
	for k in pairs(arg) do
		v = redis:getStorage(k)
		if v then
			str[#str+1] = {key=k, value=v}
		end
	end
	local result = cjson.encode({ result = str})
	ngx.say(result)
end

redis:setStorage('abc', 123)
ngx.say('old:', redis:getStorage('abc'))
redis:expireStorage('abc', -1)
ngx.say('new:', redis:getStorage('abc'))

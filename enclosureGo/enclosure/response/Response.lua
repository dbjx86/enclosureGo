local _M = { modNum = 4 }

local mt = { __index = _M }

local json = require "cjson.safe"


function _M:new(...)
	local this = {
		result = {}
	}

	setmetatable(this, mt)
	return this
end

function _M:send(success, data, err)
	if success then
		data['success'] = true
	else
		data['success'] = false
		data['errMsg'] = err
	end

	self.result = json.encode(data)
	ngx.say(self.result)
end

return _M

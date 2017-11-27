local _M = { modNum = 2 }

local mt = { __index = _M }
local redis = require "resty.redis"
local json = require "cjson.safe"

local function connect(red)
	local ok, err = red:connect("127.0.0.1", 6379)
	if not ok then
		ngx.log(ngx.ERR, "failed to connect: ", err)
		return false, "failed to connect: " .. err
	end

	return true
end

local function close(red)
	-- put it into the connection pool of size 100,
	-- with 10 seconds max idle time
	local ok, err = red:set_keepalive(10000, 100)
	if not ok then
		ngx.log(ngx.ERR, "failed to set keepalive: ", err)
		return false, "failed to set keepalive: " .. err
	end

	return true
end

function _M:new(...)
	local red = redis:new()
	red:set_timeout(1000) -- 1 sec

	local this = {
		red = red
	}

	setmetatable(this, mt)
	return this
end

function _M:setStorage(key, value)
	local ok, err = connect(self.red)
	if not ok then
		return false, err
	end

	if type(value) == 'table' then
		value = json.encode(value)
		if value == nil then
			ngx.log(ngx.ERR, "value invalid")
			return false, "value invalid"
		end
	end

	local ok, err = self.red:set(key, value)
	if not ok then
		ngx.log(ngx.ERR, "failed to set: ", err)
		return false, "failed to set: " .. err
	end

	local ok, err = close(self.red)
	if not ok then
		return false, err
	end
	return true
end

function _M:getStorage(key)
	local ok, err = connect(self.red)
	if not ok then
		return false, err
	end

	local value, err = self.red:get(key)
	if not value then
		ngx.log(ngx.ERR, "failed to get: ", err)
		return false, "failed to get: " .. err
	end

	local ok, err = close(self.red)
	if not ok then
		return false, err
	end

	--redis return userdata
	if value == ngx.null then
		return nil
	end

	return json.decode(value)
end

function _M:expireStorage(key, expire_number)
	local ok, err = connect(self.red)
	if not ok then
		return false, err
	end

	if key == nil or type(key) == 'table' then
		ngx.log(ngx.ERR, "key invalid")
		return false, "key invalid"
	end

	local ok, err = self.red:expire(key, expire_number)
	if not ok then
		ngx.log(ngx.ERR, "failed to set: ", err)
		return false, "failed to set: " .. err
	end

	local ok, err = close(self.red)
	if not ok then
		return false, err
	end
	return true
end

return _M

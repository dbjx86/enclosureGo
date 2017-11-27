local _M = { modNum = 3 }

local mt = { __index = _M }

local json = require "cjson.safe"

local function decodeArg(args)
	local arg = {}

	for k, v in pairs(args) do
		if not string.find(v, "^{") then
			arg[k] = v
		else
			local value = json.decode(v)
			if value == nil then
				local err = k..' was invalid!'
				ngx.log(ngx.ERR, err)
			else
				arg[k] = value
			end
		end
	end

	return arg
end

function _M:new(...)
	local method = ngx.req.get_method()

	local this = {
		method = method
	}

	setmetatable(this, mt)
	return this
end

function _M:getArgs()
	local args = {}

	if self.method == 'GET' then
		args = ngx.req.get_uri_args()
	elseif self.method == 'POST' then
		ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
		args = ngx.req.get_post_args()
	else
		local err = 'method was invalid'
		ngx.log(ngx.ERR, err)
		return nil, err
	end

	return decodeArg(args)
end

return _M

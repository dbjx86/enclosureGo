--封装数据操作层(数据库与缓存)
local _M = { modNum = 5 }

local mt = { __index = _M }

local redis = require ('enclosure.memory.redis'):new()
local db = require ('enclosure.db.mysql'):new()
local json = require ('cjson.safe')


local function getKey(arg)
	local key = ""

	if arg == nil then
		return nil
	end

	for i, v in ipairs(arg) do
		if i == 1 then
			key = v
		else
			key = key ..'-'.. v
		end
	end
	if key == "" then
		return nil
	end

	return key
end

function _M:new(...)
	local this = {
		redis = redis,
		db = db
	}

	setmetatable(this, mt)
	return this
end

--sql:数据库SQL(update,insert,del)
function _M:query(sql)
	local ok, err = self.db:query(sql)
	if not ok then
		return false, err
	end

	return true
end

--sql:数据库SQL(update,insert)
--data:缓存value
--arg:缓存key
function _M:queryWithMem(sql, data, ...)
	local arg = {...}

	local key = getKey(arg)
	if not key then
			local err = "Not pass parameters:key"
			ngx.log(ngx.ERR, err)
			return false, err
	end

	local ok, err = self.db:query(sql)
	if not ok then
		return false, err
	end

	if data == nil then
		local ok, err = self.redis:expireStorage(key, -1)
		if not ok then
			return false, err
		else
			return true
		end
	end

	local ok, err = self.redis:setStorage(key, data)
	if not ok then
		return false, err
	end

	return true
end

--sql:数据库SQL(select)
function _M:querySelect(sql)
	local ok, result = self.db:querySelect(sql)
	if not ok then
		return nil, err
	end

	return true, result
end

--sql:数据库SQL(select)
--data:缓存value
--arg:缓存key
function _M:querySelectWithMem(sql, ...)
	local arg = {...}

	local key = getKey(arg)
	if not key then
			local err = "Not pass parameters:key"
			ngx.log(ngx.ERR, err)
			return false, err
	end

	local result = self.redis:getStorage(key)
	if not result then
		return true, result
	end

	local ok, result = self.db:querySelect(sql)
	ngx.log(ngx.ERR, 'execute sql')
	if not ok then
		return nil, err
	end

	local ok, err = self.redis:setStorage(key, result)
	if not ok then
		return false, err
	end

	return true, result
end


return _M

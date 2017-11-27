local _M = { modNum = 1 }

local mt = { __index = _M }
local mysql = require "resty.mysql"
local config = require "enclosure.db.config"

local function connect(db)
	local ok, err, errno, sqlstate  = db:connect{
		host = config.host,
		port = config.port,
		database = config.database,
		user = config.user,
		password = config.password,
		max_packet_size = config.max_packet_size
	}
	if not ok then
		ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errno, " ", sqlstate)
		return false, "failed to connect: " .. err
	end

	return true
end

local function close(db)
	-- put it into the connection pool of size 100,
	-- with 10 seconds max idle timeout
	local ok, err = db:set_keepalive(10000, 100)
	if not ok then
		ngx.log(ngx.ERR, "failed to set keepalive: ", err)
		return false, "failed to set keepalive: ".. err
	end

	return true
end

function _M:new(...)
	local db, err = mysql:new()
	if not db then
		ngx.log(ngx.ERR, "failed to instantiate mysql: ", err)
		return false, "failed to instantiate mysql: ".. err
	end

	db:set_timeout(1000) -- 1 sec

	local this = {
		db = db
	}

	setmetatable(this, mt)
	return this
end

function _M:querySelect(sql)
	local ok, err = connect(self.db)
	if not ok then
		return false, err
	end

	-- run a select query
	-- the result set:
	local res, err, errno, sqlstate = self.db:query(sql)
	if not res then
		ngx.log(ngx.ERR, "bad result: ", err, ": ", errno, ": ", sqlstate, ".")
		return false, "bad result: " .. err
	end

	local cjson = require "cjson"
	local result = cjson.encode(res)

	local ok, err = close(self.db)
	if not ok then
		return false, err
	end
	return true, result
end

function _M:query(sql)
	local ok, err = connect(self.db)
	if not ok then
		return false, err
	end

	-- run a select query
	-- the result set:
	local res, err, errno, sqlstate = self.db:query(sql)
	if not res then
		ngx.log(ngx.ERR, "bad result: ", err, ": ", errno, ": ", sqlstate, ".")
		return false, "bad result: " .. err
	end

	local ok, err = close(self.db)
	if not ok then
		return false, err
	end
	return true, res.affected_rows
end

return _M

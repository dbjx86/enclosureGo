--上传用户定位信息
--请求参数
--	{
--		user_id:用户ID
--		location_type:定位类型(例如:1,2,3)
--		longitude:经度
--		latitude:纬度
--	}
--返回值
--	成功:{
--		success: "true"-成功
--		newLocation: "1"-新定位/"0"-更新定位
--	}
--	失败:{
--		success: "false"-失败
--		errMsg: "错误信息"
--	}

local request = require ('enclosure.request.Request'):new()
local response = require ('enclosure.response.Response'):new()
local redis = require ('enclosure.memory.redis'):new()
local db = require ('enclosure.db.mysql'):new()


local function addLocation(args, location_key)
	local update_time = ngx.localtime()
	local sql = string.format([[insert into user_location (user_id, location_type, longitude, latitude, update_time)  values('%s', '%d', '%s', '%s', '%s')]], args.user_id, args.location_type, args.longitude, args.latitude, update_time)

	local ok = db:query(sql)
	if not ok then
		return false
	end

	args['update_time'] = update_time
	if redis:setStorage(location_key, args) == false then
		return false
	end

	return true
end

local function updateLocation(args, location_key)
	local update_time = ngx.localtime()
	local sql = string.format([[update user_location set longitude = '%s', latitude = '%s', update_time = '%s' where user_id = '%s' and location_type = '%d']], args.longitude, args.latitude, update_time, args.user_id, args.location_type)

	local ok = db:query(sql)
	if not ok then
		return false
	end

	args['update_time'] = update_time
	if redis:setStorage(location_key, args) == false then
		return false
	end

	return true
end


local args = request:getArgs()
local ok = false
local newLocation = 0
local location_key = args.user_id .. '-' .. args.location_type
--todo:args check

local locationInfo = redis:getStorage(location_key)

if not locationInfo then
	ok = addLocation(args, location_key)
	newLocation = 1
else
	ok = updateLocation(args, location_key)
end

if not ok then
	response:send(false, {}, "uploadLocation fail!")
else
	response:send(true, {newLocation=newLocation})
end


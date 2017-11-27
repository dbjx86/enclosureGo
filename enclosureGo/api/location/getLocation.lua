--获取用户定位信息
--请求参数
--	{
--		user_id:用户ID
--	}
--返回值
--	成功:{
--		success: "true"-成功
--		locationInfo: 用户定位信息(object)
--	}
--		其中locationInfo:{
--			location : [
--				{	
--					longitude: 经度
--					latitude: 纬度
--					location_type:定位类型(例如:1,2,3)
--					update_time: 定位时间
--				}
--			]
--		}
--	失败:{
--		success: "false"-失败
--		errMsg: "错误信息"
--	}

local request = require ('enclosure.request.Request'):new()
local response = require ('enclosure.response.Response'):new()
local redis = require ('enclosure.memory.redis'):new()
local db = require ('enclosure.db.mysql'):new()

--可定位点数
local locationCount = 3


local function findLocation(args)
	local update_time = ngx.localtime()
	local sql = string.format([[select longitude, latitude, location_type, update_time from user_location where user_id = '%s' and update_time = '%d']], args.user_id, )

	local ok = db:query(sql)
	if not ok then
		return false
	end

	return true
end


local function findLocationInfo(args)
	local locationInfo = {}

	for i=1, locationCount, 1 do
		local location = redis:getStorage(args.user_id .. '-' .. i)
		if not location then
			locationInfo = findLocation(args)
			return locationInfo
		end
		locationInfo[#locationInfo + 1] = location
	end

	return locationInfo
end


local args = request:getArgs()
local locationInfo = findLocationInfo(args)

if not locationInfo then
	response:send(false, {}, "findLocation fail!")
else
	response:send(true, {locationInfo=locationInfo})
end


--上传用户信息:返回用户ID,新用户增加其用户信息
--请求参数
--	{
--		wetchat_id: 微信openid
--		nickName: 昵称
--		avatarUrl: 头像
--		gender:性别
--		province:省
--		city:市
--		country:国
--	}
--返回值
--	成功:{
--		success: "true"-成功
--		newUser: "0"-老用户/"1"-新用户
--		user_id: 用户ID
--	}
--	失败:{
--		success: "false"-失败
--	errMsg: "错误信息"
--	}

local request = require ('enclosure.request.Request'):new()
local response = require ('enclosure.response.Response'):new()
local redis = require ('enclosure.memory.redis'):new()
local db = require ('enclosure.db.mysql'):new()
local random = require ('enclosure.common.random')
local json = require ('cjson.safe')


local function addNewUser(args)
	local user_id = random:getId()
	local sql = string.format([[insert into user (user_id, wetchat_id, nickName, avatarUrl, gender, province, city, country)  values('%s', '%s', '%s', '%s', %d, '%s', '%s', '%s')]], user_id, args.wetchat_id, args.nickName, args.avatarUrl, args.gender, args.province, args.city, args.country)

	local ok = db:query(sql)
	if not ok then
		return false
	end

	args['user_id'] = user_id
	local userInfo = args
	if redis:setStorage(args.wetchat_id, userInfo) == false then
		return false
	end

	return true, 1, user_id
end


local args = request:getArgs()
local ok = false
local newUser = 0
local user_id = nil
--todo:args check

local userInfo = redis:getStorage(args.wetchat_id)

if not userInfo then
	ok, newUser, user_id = addNewUser(args)
else
	ok = true
	user_id = userInfo.user_id
end

if not ok then
	response:send(false, {}, "addUser fail!")
else
	response:send(true, {newUser=newUser, user_id=user_id})
end


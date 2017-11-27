local request = require ('enclosure.request.Request'):new()
local response = require ('enclosure.response.Response'):new()
local store = require ('enclosure.store.Store'):new()
local random = require ('enclosure.common.random')


local args = request:getArgs()

function insert()
	local sql = string.format([[insert into user (user_id, wetchat_id, nickName, avatarUrl, gender, province, city, country)  values('%s', '%s', '%s', '%s', %d, '%s', '%s', '%s')]], random:getId(), args.wetchat_id, args.nickName, args.avatarUrl, args.gender, args.province, args.city, args.country)
	local ok, res = store:queryWithMem(sql, args, args.wetchat_id, args.gender)
	if not ok then
		ngx.say("insert db fail!")
	else
		ngx.say('ok!')
	end
end

function find()
	local sql = string.format("select * from user")
	if args.id then
		sql = sql .. string.format(" where user_id = '%s'", args.id)
	end
	local ok, res = store:querySelectWithMem(sql, args.wechat_id)
	if not ok then
		ngx.say("query db fail!")
	else
		ngx.say(res)
	end

	return res
end

function delete()
	local sql = string.format("delete from user")
	if args.id then
		sql = sql .. string.format(" where user_id = '%s'", args.id)
	end
	local ok, res = store:query(sql)
	if not ok then
		ngx.say("query db fail!")
	else
		ngx.say(res)
	end
end

function update()
	local sql = string.format("update user")
	if args.wetchat_id then
		sql = sql .. string.format(" set nickName = '%s' where wetchat_id = '%s'", args.nickName, args.wetchat_id)
	end
	local ok, res = store:queryWithMem(sql, nil, args.wetchat_id, args.gender)
	if not ok then
		ngx.say("query db fail!")
	else
		ngx.say(res)
	end
end

update()
response:send(true, {action = 'update'})
--insert()
--response:send(true, {action = 'insert'})
--respone:send(true, {action = 'find', res = find()})

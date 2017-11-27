local db = require ('enclosure.db.mysql'):new()
local random = require ('enclosure.common.random')

local arg = ngx.req.get_uri_args()

function insert()
	for k, v in pairs(arg) do
		if k == 'user_id' then
			user_id = v
		end
		if k == 'wetchat_id' then
			wetchat_id = v
		end
		if k == 'nickName' then
			nickName = v
		end
		if k == 'avatarUrl' then
			avatarUrl = v
		end
		if k == 'gender' then
			gender = v
		end
		if k == 'province' then
			province = v
		end
		if k == 'city' then
			city = v
		end
		if k == 'province' then
			country = v
		end
	end
	local sql = string.format([[insert into user (user_id, wetchat_id, nickName, avatarUrl, gender, province, city, country)  values('%s', '%s', '%s', '%s', %d, '%s', '%s', '%s')]], random:getId(), wetchat_id, nickName, avatarUrl, gender, province, city, country)
	local ok, res = db:query(sql)
	if not ok then
		ngx.say("insert db fail!")
	else
		ngx.say('ok!')
	end
end

function find()
	local sql = string.format("select * from user")
	if arg.id then
		sql = sql .. string.format(" where user_id = '%s'", arg.id)
	end
	ngx.log(ngx.ERR, sql)
	local ok, res = db:querySelect(sql)
	if not ok then
		ngx.say("query db fail!")
	else
		ngx.say(res)
	end
end

function delete()
	local sql = string.format("delete from user")
	if arg.id then
		sql = sql .. string.format(" where user_id = '%s'", arg.id)
	end
	local ok, res = db:query(sql)
	if not ok then
		ngx.say("query db fail!")
	else
		ngx.say(res)
	end
end

function update()
	local sql = string.format("update user")
	if arg.id then
		sql = sql .. string.format(" set nickName = '%s' where user_id = '%s'", arg.name, arg.id)
	end
	local ok, res = db:query(sql)
	if not ok then
		ngx.say("query db fail!")
	else
		ngx.say(res)
	end
end



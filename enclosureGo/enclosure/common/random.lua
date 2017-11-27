local _M = { modNum = 0 } 

local mt = { __index = _M }

function ensureSeeded()
	
	if not isSeeded then
	 	local workerId = ngx.worker.pid()
	 	ngx.update_time()
		local t = ngx.now() * 1000 
		local st = string.reverse(string.sub(t, 6, -1))
	 
		st = workerId .. st

		t = tonumber(st)

		math.randomseed(t)

		isSeeded = true
	end
end

	--生成随机ID
function _M:getId()
	ensureSeeded()

	local guid
	local seed = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j'}
	local tb = {}
	for i = 1, 32 do
		table.insert(tb, seed[math.random(1, 20)])
	end
	local sid = table.concat(tb)

	guid = sid

	return guid
end

return _M

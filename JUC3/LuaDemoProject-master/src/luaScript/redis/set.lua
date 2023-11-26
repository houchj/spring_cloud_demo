--- 此脚本的环境： redis 内部，不是运行在 nginx 内部

--- demo get value
---

--[[  set key val
--]]
local key = KEYS[1]
local val = ARGV[1]

return redis.call('set', key, val)


-- /usr/local/redis/bin/redis-cli  --eval  /usr/local/lua/set.lua  key1 , value1

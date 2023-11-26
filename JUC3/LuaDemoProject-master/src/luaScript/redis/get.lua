--- 此脚本的环境： redis 内部，不是运行在 nginx 内部

---  demo set value
---

--[[
redis: get key
--]]


local key = KEYS[1]
local val = redis.call("GET", key);

return val;


-- /usr/local/redis/bin/redis-cli  --eval  /usr/local/lua/get.lua  key1


--- 此脚本的环境： redis 内部，不是运行在 nginx 内部
-- 返回 0 表示被限流
-- 返回 其他 表示统计的次数
local cacheKey =  KEYS[1]
local data = redis.call("incr", cacheKey)
local count=tonumber(data)

-- 首次访问，设置过期时间
if count == 1 then
    redis.call("expire", cacheKey, 10) -- 设置超时时间10s
end

if count > 10 then   -- 设置超过的限制为10人
    return 0; --0 表示需要限流
end

--redis.debug(redis.call("get", cacheKey))
return  count;




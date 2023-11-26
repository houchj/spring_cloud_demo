--- 此脚本的环境： redis 内部，不是运行在 nginx 内部
--- 0 no setting
--- -1 failed
--- 1 success
--- @param key key
--- @param permits  quantity

local function acquire(key, permits)
    local times = redis.call('TIME');
    -- times[1] 秒数   -- times[2] 微秒数
    local curr_mill_second = times[1] * 1000000 + times[2];
    curr_mill_second = curr_mill_second / 1000;

    local rate_limit_info = redis.pcall("HMGET", key, "last_mill_second", "curr_permits", "max_permits", "rate")
    local last_mill_second = rate_limit_info[1];
    local curr_permits = tonumber(rate_limit_info[2]);
    local max_permits = tonumber(rate_limit_info[3]);
    local rate = rate_limit_info[4];

    local local_curr_permits = max_permits;

    if (type(last_mill_second) ~= 'boolean' and last_mill_second ~= nil) then
        local reverse_permits = math.floor(((curr_mill_second - last_mill_second) / 1000) * rate)
        local expect_curr_permits = reverse_permits + curr_permits;
        local_curr_permits = math.min(expect_curr_permits, max_permits);

        if (reverse_permits > 0) then
            redis.pcall("HSET", key, "last_mill_second", curr_mill_second)
        end
    else
        redis.pcall("HSET", key, "last_mill_second", curr_mill_second)
    end

    local result = -1
    if (local_curr_permits - permits >= 0) then
        result = 1
        redis.pcall("HSET", key, "curr_permits", local_curr_permits - permits)
    else
        redis.pcall("HSET", key, "curr_permits", local_curr_permits)
    end

    return result
end
--eg
-- /usr/local/redis/bin/redis-cli  --eval   /vagrant/LuaDemoProject/src/luaScript/redis/rate_limiter.lua key , acquire 1  1



local function init(key, max_permits, rate)
    local rate_limit_info = redis.pcall("HMGET", key, "last_mill_second", "curr_permits", "max_permits", "rate")
    local org_max_permits = tonumber(rate_limit_info[3])
    local org_rate = rate_limit_info[4]

    if (org_max_permits == nil) or (rate ~= org_rate or max_permits ~= org_max_permits) then
        redis.pcall("HMSET", key, "max_permits", max_permits, "rate", rate, "curr_permits", max_permits)
    end
    return 1;
end
--eg
-- /usr/local/redis/bin/redis-cli  --eval   /vagrant/LuaDemoProject/src/luaScript/redis/rate_limiter.lua key , init 1  1

local function delete(key)
    redis.pcall("DEL", key)
    return 1;
end
--eg
-- /usr/local/redis/bin/redis-cli  --eval   /vagrant/LuaDemoProject/src/luaScript/redis/rate_limiter.lua key , delete



local key = KEYS[1]
local method = ARGV[1]

if method == 'acquire' then
    return acquire(key, ARGV[2], ARGV[3])
elseif method == 'init' then
    return init(key, ARGV[2], ARGV[3])
elseif method == 'delete' then
    return delete(key)
else
    --ignore
end


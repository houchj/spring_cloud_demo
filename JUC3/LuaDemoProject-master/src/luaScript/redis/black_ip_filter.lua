
--导入自定义的基础模块
local basic = require("luaScript.module.common.basic");
--导入自定义的 RedisOperator 模块
local redisOp = require("luaScript.redis.RedisOperator");


local ip = basic.getClientIP();
basic.log("ClientIP:"..ip);
-- lua_shared_dict black_ip_list 1m; #配置文件定义的 ip_blacklist 共享内存变量
local black_ip_list = ngx.shared.black_ip_list


--获得本地缓存的刷新时间,如果没有过期，则直接使用
local last_update_time = black_ip_list:get("last_update_time");

if last_update_time ~= nil then
    local dif_time = ngx.now() - last_update_time
    if dif_time < 60 then --缓存1分钟,没有过期
        if black_ip_list:get(ip) then
            return ngx.exit(ngx.HTTP_FORBIDDEN) --直接返回403
        end
        return
    end
end

local KEY = "limit:ip:blacklist";
--创建自定义的redis操作对象
local red = redisOp:new();
--打开连接
red:open();
--获取缓存的黑名单
local ip_blacklist = red:getSmembers(KEY);
--归还连接到连接池
red:close();

if not ip_blacklist then
    basic.log("black ip set  is null");
    return;
else
    --刷新本地缓存
    black_ip_list:flush_all();

    --同步redis黑名单 到 本地缓存
    for i,ip in ipairs(ip_blacklist) do
        --本地缓存redis中的黑名单
        black_ip_list:set(ip,true);
    end
    --设置本地缓存的最新更新时间
    black_ip_list:set("last_update_time",ngx.now());
end
if black_ip_list:get(ip) then
    return ngx.exit(ngx.HTTP_FORBIDDEN) --直接返回403
end







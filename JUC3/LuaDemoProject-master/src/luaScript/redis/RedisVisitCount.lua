

--导入自定义的 RedisOperator 模块
local redisOp = require("luaScript.redis.RedisOperator");

--创建自定义的redis操作对象
local red = redisOp:new();
--打开连接
red:open();

--获取访问次数
local visitCount = red:incrValue("demo:visitCount");

if visitCount == 1 then
    --10s内过期
    red:expire("demo:visitCount", 10);
end
--将访问次数，设置到 Nginx 变量
ngx.var.count = visitCount;
--归还连接到连接池
red:close();
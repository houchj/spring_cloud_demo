--- 此脚本的环境：  nginx 内部


--导入自定义的基础模块
--local basic = require("luaScript.module.common.basic");
--导入自定义的 redis操作 模块
local redisExecutor = require("luaScript.redis.RedisOperator");


local errorOut = { respCode = -1, resp_msg = "限流出错", datas = {} };

-- 取得用户的ip
local shortKey =  ngx.var.remote_addr;

-- 没有限流关键字段， 提示错误
if not shortKey or shortKey == ngx.null then
    errorOut.resp_msg = "shortKey 不能为空"
    ngx.say(cjson.encode(errorOut));
    return ;
end

-- 拼接计数的 redis key
local key = "ip:" .. shortKey;


-- 获取 sha编码的命令
-- /usr/local/redis/bin/redis-cli script load "$(cat  /vagrant/LuaDemoProject/src/luaScript/module/ratelimit/redis_rate_limiter.lua)"
-- /usr/local/redis/bin/redis-cli  script exists  2c95b6bc3be1aa662cfee3bdbd6f00e8115ac657

local rateLimiterSha = "2c95b6bc3be1aa662cfee3bdbd6f00e8115ac657";



--创建自定义的redis操作对象
local red = redisExecutor:new();
--打开连接
red:open();
local connection=red:getConnection();

--执行限流的redis 内部脚本
local resp, err = connection:evalsha(rateLimiterSha, 1,key);
--归还连接到连接池
red:close();

--这里要注意判空的方式
if not resp or resp == ngx.null then
    errorOut.resp_msg=err;
    ngx.say(cjson.encode(errorOut));
    ngx.exit(ngx.HTTP_UNAUTHORIZED);
    return ;
end

local count = tonumber(resp);

-- 如果通过流控
if count==0 then
    errorOut.resp_msg = "抱歉，被限流了";
    ngx.say(cjson.encode(errorOut),"<br>");
    ngx.exit(ngx.HTTP_UNAUTHORIZED);
    return ;
end

--设置ngx的变量
ngx.var.count = count;
-- 注意，在这里直接输出，会导致content 阶段的指令被跳过
-- ngx.say( "目前的访问总数：",count,"<br>");
return;
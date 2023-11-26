--- 此脚本的环境：  nginx 内部，不是运行在 redis 内部


--导入自定义的基础模块
--local basic = require("luaScript.module.common.basic");
--导入自定义的 dataType 模块
local redisExecutor = require("luaScript.redis.RedisOperator");


--读取get参数
--local uri_args = ngx.req.get_uri_args()
--读取post参数
ngx.req.read_body();
--local uri_args = ngx.req.get_post_args()
local data = ngx.req.get_body_data(); --获取消息体
local skuId =nil;
--ngx.say(data)
if not data or nil == data then
    --读取get参数
    local get_args = ngx.req.get_uri_args()
    skuId = get_args["seckillSkuId"];
else
    local args = cjson.decode(data);
    skuId = args["seckillSkuId"];
end

if not skuId or  nil == skuId then
    skuId =  ngx.var.skuId;
end
--ngx.say("skuId=" .. skuId)
--ngx.say("userId=" .. userId)
local errorOut = { respCode = -1, resp_msg = "限流出错", datas = {} };

local key = "rate_limiter:seckill:" .. skuId;

-- 获取 sha编码的命令
-- /usr/local/redis/bin/redis-cli -a 123456 script load "$(cat  /vagrant/LuaDemoProject/src/luaScript/redis/rate_limiter.lua)"
-- /usr/local/redis/bin/redis-cli -a 123456  script exists  75e0f0c8ab378aa178c3d7fe2aeabc4fc0e289fa
-- /usr/local/redis/bin/redis-cli -a 123456  evalsha   75e0f0c8ab378aa178c3d7fe2aeabc4fc0e289fa 1 "rate_limiter:seckill:4b70903f6e1aa87788d3ea962f8b2f0e"  init 1  1
-- /usr/local/redis/bin/redis-cli -a 123456  evalsha   75e0f0c8ab378aa178c3d7fe2aeabc4fc0e289fa 1 "rate_limiter:seckill:4b70903f6e1aa87788d3ea962f8b2f0e"  acquire 1
-- /usr/local/redis/bin/redis-cli  -a 123456  set "rate_limiter:sha1"  75e0f0c8ab378aa178c3d7fe2aeabc4fc0e289fa
-- /usr/local/redis/bin/redis-cli  -a 123456  get "rate_limiter:sha1"

-- local rateLimiterSha = "e4e49e4c7b23f0bf7a2bfee73e8a01629e33324b";
--eg
-- /usr/local/redis/bin/redis-cli  --eval   /vagrant/LuaDemoProject/src/luaScript/redis/rate_limiter.lua rate_limiter:seckill:1 , init 1  1


-- 访问的路径 http://cdh1/ratelimit/demo2?seckillSkuId=1

local rateLimiterSha = nil;
--创建自定义的redis操作对象
local red = redisExecutor:new();
--打开连接
red:open();

-- 获取限流 lua 脚本的sha1 编码
rateLimiterSha = red:getValue("rate_limiter:sha1");

-- redis 没有缓存秒杀脚本
if not rateLimiterSha or rateLimiterSha == ngx.null then
    errorOut.resp_msg = "秒杀还未启动,请先启动秒杀";
    ngx.say(cjson.encode(errorOut));
    --归还连接到连接池
    red:close();
    return ;
end
ngx.log(ngx.DEBUG,"key=" .. tostring(key))

local connection = red:getConnection();
local resp, err = connection:evalsha(rateLimiterSha, 1, key, "acquire", "1");


--归还连接到连接池
red:close();

if not resp or resp == ngx.null then
    errorOut.resp_msg = err;
    ngx.say(cjson.encode(errorOut));
    return ;
end

local flag = tonumber(resp);
--ngx.say("flag="..flag);
if flag ~= 1 then
    errorOut.resp_msg = "抱歉，被限流了";
    ngx.say(cjson.encode(errorOut));
    ngx.exit(ngx.HTTP_UNAUTHORIZED);
end
return ;
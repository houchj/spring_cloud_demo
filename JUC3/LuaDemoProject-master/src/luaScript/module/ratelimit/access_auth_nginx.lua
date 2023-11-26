--- 此脚本的环境：  nginx 内部

--导入自定义的基础模块
--local basic = require("luaScript.module.common.basic");
--导入自定义的 计数器模块
local RedisKeyRateLimiter = require("luaScript.module.ratelimit.RedisKeyRateLimiter");


--定义出错的JSON输出对象
local errorOut = { respCode = -1, resp_msg = "限流出错", datas = {} };

--读取get参数读取get参数
local args = ngx.req.get_uri_args()
--读取post参数
--ngx.req.read_body();
--local uri_args = ngx.req.get_post_args()
--local data = ngx.req.get_body_data(); --获取消息体
--ngx.say(data)

--local shortKey = args["seckillSkuId"];
--ngx.say("shortKey=" .. shortKey)

-- 取得用户的ip
local shortKey =  ngx.var.remote_addr;

-- 没有限流关键字段， 提示错误
if not shortKey or shortKey == ngx.null then
    errorOut.resp_msg = "shortKey 不能为空"
    ngx.say(cjson.encode(errorOut));
    return ;
end

-- 拼接计数的 redis key
local key = "count_rate_limit:ip:" .. shortKey;

local limiter = RedisKeyRateLimiter:new(key);

local passed = limiter:acquire();

-- 如果通过流控
if passed then
    ngx.var.count = limiter:getCount();
    -- 注意，在这里直接输出，会导致content 阶段的指令被跳过
    -- ngx.say( "目前的访问总数：",limiter:getCount(),"<br>");
end

--回收redis 连接
limiter:close();

-- 如果没有流控，终止nginx的处理流程
if not passed then
    errorOut.resp_msg = "抱歉，被限流了";
    ngx.say(cjson.encode(errorOut));
    ngx.exit(ngx.HTTP_UNAUTHORIZED);
end

return ;
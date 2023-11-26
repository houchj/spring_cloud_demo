--- 此脚本的环境：  nginx 内部，不是运行在 redis 内部


--导入自定义的基础模块
--local basic = require("luaScript.module.common.basic");
--导入自定义的 dataType 模块
local redisExecutor = require("luaScript.redis.RedisOperator");
--导入自定义的 uuid 模块
local uuid = require 'luaScript.module.common.uuid'
--ngx.print("======" .. uuid.generate())

--读取get参数
--local uri_args = ngx.req.get_uri_args()
--读取post参数
ngx.req.read_body();
--local uri_args = ngx.req.get_post_args()
--local data = ngx.req.get_body_data(); --获取消息体
local headers = ngx.req.get_headers();
--ngx.say(data)

--local args = cjson.decode(data);
--local exposedKey = args["exposedKey"];
local exposedKey = ngx.var[1];
local userId = headers["USER-ID"];
local token = uuid.generate();


ngx.log(ngx.DEBUG,"userId=" .. tostring(userId))
ngx.log(ngx.DEBUG,"exposedKey=" .. tostring(exposedKey))
ngx.log(ngx.DEBUG,"token=" .. tostring(token))


-- 获取 sha编码的命令
-- /usr/local/redis/bin/redis-cli script load "$(cat  /vagrant/LuaDemoProject/src/luaScript/module/seckill/seckill.lua)"
-- /usr/local/redis/bin//redis-cli  script exists  8f95247ae10a234c867db0c087a9621d75d77ea4

local restOut = { respCode = 0, resp_msg = "操作成功", datas = {} };
local errorOut = { respCode = -1, resp_msg = "操作失败", datas = {} };

local seckillSha = nil;

--创建自定义的redis操作对象
local red = redisExecutor:new();
--打开连接
red:open();

-- 获取lua 脚本的sha1 编码
seckillSha=red:getValue("seckill:lua:sha1");

-- /usr/local/redis/bin/redis-cli -a  123456  SCRIPT LOAD "$(cat /vagrant/LuaDemoProject/src/luaScript/module/seckill/seckill.lua)"


--seckillSha="f435b5855c0d3e40ddde27dbc93a4dfa32e37ef1";
ngx.log(ngx.DEBUG,"seckillSha from redis=" .. tostring(seckillSha))

-- redis 没有缓存秒杀脚本
if not seckillSha or seckillSha == ngx.null then
    --归还连接到连接池
    red:close();

    errorOut.resp_msg="秒杀还未启动";
    ngx.say(cjson.encode(errorOut));
    return ;
end

--执行秒杀脚本
local rawFlag = red:evalSeckillSha(seckillSha, "setToken", exposedKey, userId, token);
--归还连接到连接池
red:close();
if not rawFlag or rawFlag == ngx.null then
    errorOut.resp_msg="秒杀执行失败";
    ngx.say(cjson.encode(errorOut));
    return ;
end

local flag = tonumber(rawFlag);

if flag == 5 then
    errorOut.resp_msg = "已经排队过了";
    ngx.say(cjson.encode(errorOut));
    return ;
end
if flag == 2 then
    errorOut.resp_msg = "秒杀商品没有找到";
    ngx.say(cjson.encode(errorOut));
    return ;
end

if flag == 4 then
    errorOut.resp_msg = "库存不足,稍后再来";
    ngx.say(cjson.encode(errorOut));
    return ;
end

if flag ~= 1 then
    errorOut.resp_msg = "排队失败,未知错误";
    ngx.say(cjson.encode(errorOut));
    return ;
end

restOut.datas = token;
ngx.say(cjson.encode(restOut));

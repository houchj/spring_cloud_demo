
--导入自定义的基础模块
local basic = require("luaScript.module.common.basic");
--导入自定义的 RedisOperator 模块
local redisOp = require("luaScript.redis.RedisOperator");

local PREFIX = "GOOD_CACHE:"

-- RedisCacheDemo类
local _RedisCacheDemo = { }
_RedisCacheDemo.__index = _RedisCacheDemo


-- 类的方法 new
function _RedisCacheDemo.new(self)
    local object = {}
    setmetatable(object, self)
    return object;
end


-- 类的方法
function _RedisCacheDemo.getParam(self, paramName)
    --Nginx服务器中使用lua获取get或post参数
    local request_method = ngx.var.request_method
    local args = nil
    --获取参数的值
    if "GET" == request_method then
        args = ngx.req.get_uri_args()
    elseif "POST" == request_method then
        ngx.req.read_body()
        args = ngx.req.get_post_args()
    end
    if not args then
        return nil
    end
    return args[paramName]
end

--取得缓存
function _RedisCacheDemo.getCache(self,skuId)

    --创建自定义的redis操作对象
    local red = redisOp:new();
    --打开连接
    if not  red:open() then
        basic:error("redis 连接失败");
        return nil;
    end

    --获取缓存数据
    local json = red:getValue(PREFIX .. skuId);
    red:close();

    if not json or json==ngx.null then
        basic:log(skuId .. "的缓存没有取到");
        return nil;
    end
    basic:log(skuId .. "缓存成功命中");
    return json;
end


--优先从缓存获取，否则访问上游接口
function _RedisCacheDemo.goUpstream(self)
    local request_method = ngx.var.request_method
    local args = nil
    --获取参数的值
    if "GET" == request_method then
        args = ngx.req.get_uri_args()
    elseif "POST" == request_method then
        ngx.req.read_body()
        args = ngx.req.get_post_args()
    end

    --回源上游接口,比如Java 后端rest接口
    local res = ngx.location.capture("/java/sku/detail",{
        method = ngx.HTTP_GET,
        args = args  -- 重要：将请求参数，原样向上游传递
    })
    basic:log("上游数据获取成功");

    --返回上游接口的响应体 body
    return res.body;
end


--设置缓存,模拟Java后台
function _RedisCacheDemo.setCache(self, skuId,skuString)

    --创建自定义的redis操作对象
    local red = redisOp:new();
    --打开连接
    if not  red:open() then
        basic:error("redis 连接失败");
        return nil;
    end

    --set 缓存数据
    red:setValue(PREFIX .. skuId,skuString);
    --60s内过期
    red:expire(PREFIX .. skuId, 60);
    basic:log(skuId .. "缓存设置成功");
    --归还连接到连接池
    red:close();
    return json;
end

return _RedisCacheDemo;

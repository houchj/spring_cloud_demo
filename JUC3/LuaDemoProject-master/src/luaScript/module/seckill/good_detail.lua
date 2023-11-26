--- 此脚本的环境：  nginx 内部，不是运行在 redis 内部


--local restOut = { respCode = 0, resp_msg = "操作成功", datas = {} };
local errorOut = { respCode = -1, resp_msg = "操作失败", datas = {} };

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
local requestBody = ngx.req.get_body_data(); --获取消息体

--ngx.say(data)

local args = cjson.decode(requestBody);
local skuId = args["seckillSkuId"];
local userId = args["userId"];

-- ngx.say("skuId=" .. skuId)
-- ngx.say("userId=" .. userId)
ngx.log(ngx.DEBUG,"userId=" .. userId)
ngx.log(ngx.DEBUG,"skuId=" .. skuId)
if skuId == "" or skuId == nil then
    errorOut.resp_msg = "商品id不能为空";
    ngx.say(cjson.encode(errorOut));
    return ;
end


--优先从缓存获取，否则访问上游接口
local seckill_cache = ngx.shared.seckill_cache
local skuIdCacheKey = "skuId_" .. skuId
local skuCache = seckill_cache:get(skuIdCacheKey)
--ngx.log(ngx.DEBUG,"skuCache=" .. skuCache)

if skuCache == "" or skuCache == nil then

    ngx.log(ngx.DEBUG,"cache not hited " .. skuId)

    --回源上游接口,比如Java 后端rest接口
    local res = ngx.location.capture("/stock-provider/api/seckill/sku/detail/v1", {
        method = ngx.HTTP_POST,
        -- args = requestBody ,  -- 重要：将请求参数，原样向上游传递
        always_forward_body = false, -- 也可以设置为false 仅转发put和post请求方式中的body.
    })

    if res.status == ngx.HTTP_OK then
        --返回上游接口的响应体 body
        skuCache = res.body;
        ngx.log(ngx.DEBUG,"skuCache=" .. skuCache)

        --单位为s
        seckill_cache:set(skuIdCacheKey, skuCache, 10 * 60 * 60)
    end
end
ngx.say(skuCache);

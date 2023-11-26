--导入自定义的模块
local basic = require("luaScript.module.common.basic");
--导入自定义的 RedisOperator 模块
local redisExecutor = require("luaScript.redis.RedisOperator");


--一个统一的模块对象
local _Module = {}

_Module.__index = _Module

-- 类的方法 new
function _Module.new(self, key)
    local object = { red = nil }
    setmetatable(object, self)

    --创建自定义的redis操作对象
    local red = redisExecutor:new();

    red:open();
    object.red = red;
    object.key = "count_rate_limit:" .. key;

    basic.log("key ", object.key)
    return object
end


-- 类的方法： 判断是否能通过流控
-- 返回值 true 通过流量控制   false 被限制
function _Module.acquire(self)
    local redis = self.red;
    local current = redis:getValue(self.key);

    local limited = current and current ~= ngx.null and tonumber(current) > 10;

    if limited then
        basic.log("限流成功，已经超过了10次")
        redis:incrValue(self.key);
        return false;
    end

    if not current or current == ngx.null then
        redis:setValue(self.key, 1);
        redis:expire(self.key, 10);
    else
        redis:incrValue(self.key);
    end
    return true;
end


-- 类的方法： 取得访问次数
function _Module.getCount(self)

    local current = self.red:getValue(self.key);
    if current and current ~= ngx.null then
        return tonumber(current);
    end

    return 0;
end

-- 类的方法：归还redis 连接
function _Module.close(self)
    self.red:close();
end

return _Module

--导入自定义的模块
local basic = require("luaScript.module.common.basic");


-- 日志类
local  _LogDemo = { }
_LogDemo.__index = _LogDemo
-- 类的方法
function _LogDemo.error(self,content)
    ngx.log(ngx.ERR, content)
end
function _LogDemo.info(self,content)
    ngx.log(ngx.INFO, content)
end
function _LogDemo.debug(self,content)
    ngx.log(ngx.DEBUG, content)
end


-- 类的方法 new
function _LogDemo.new(self)
    local cls = {}
    setmetatable(cls, self)
    return cls
end

return  _LogDemo;
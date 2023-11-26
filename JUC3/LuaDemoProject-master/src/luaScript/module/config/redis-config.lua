-- 定义一个统一的redis 配置模块

-- 统一的模块对象
local _Module = {
    -- redis 服务器的地址
    host_name = "172.26.9.107";
    --host_name = "192.168.56.121";
    --host_name = "cdh1";

-- redis 服务器的端口
port = "6379";

-- redis 服务器的数据库
db = "0";

-- redis 服务器的密码
password = '123456';

    --连接超时时长
    timeout = 20000;

    -- 线程池的连接数量
    pool_size = 100;

    -- 最大的空闲时间 ,单位：毫秒
    pool_max_idle_time = 10000;

}


return _Module
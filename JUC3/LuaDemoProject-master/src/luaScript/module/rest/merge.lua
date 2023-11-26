
--导入自定义的基础模块
local basic = require("luaScript.module.common.basic");

--启用cjson处理json
gcjson = require("cjson");
--子请求
function goUpstream()
    local request_method = ngx.var.request_method
    local args = nil;
    local sendMethod = nil;
    --获取参数的值
    if "GET" == request_method then
        args = ngx.req.get_uri_args();
        sendMethod = ngx.HTTP_GET;
    elseif "POST" == request_method then
        ngx.req.read_body();
        args = ngx.req.get_post_args();
        sendMethod = ngx.HTTP_POST;
    end
    ngx.req.set_header("Content-Type", "application/json;charset=utf8");
    ngx.req.set_header("Accept", "application/json");
    ngx.req.set_header("Accept-Encoding", "")

    --批量请求
    local reqs = {};
    local theme = { "/url", {
        method = sendMethod,
        args = args  -- 重要：将请求参数，原样向上游传递
    } };

    local org = { "/url2/v1", {
        method = sendMethod,
        args = args  -- 重要：将请求参数，原样向上游传递
    } };

    local priv = { "/url3/v1", {
        method = sendMethod,
        args = args  -- 重要：将请求参数，原样向上游传递
    } };
    table.insert(reqs, theme);
    table.insert(reqs, org);
    table.insert(reqs, priv);
        local resp = nil;
        -- 统一发请求，然后等待结果
        local resps = { ngx.location.capture_multi(reqs) };
        -- 迭代结果列表
        local data ={};
        for i, res in ipairs(resps) do
        if res.status == ngx.HTTP_OK then
            resp=res;
            data[i]= gcjson.decode(res.body);
        else
            data[i]= {content="null"};
        end
        data[i]["url"]=reqs[i];
    end

    if not resp then
        resp=resps[0];
    end
    basic:log("上游数据获取成功");
    --获取状态码
    ngx.status = resp.status;

    --获取响应头
    for k, v in pairs(resp.header) do
        if k ~= "Transfer-Encoding" and k ~= "Connection" then
            ngx.header[k] = v
        end
    end
    ngx.header["Pragma"]="no-cache";
    ngx.header["Expires"]="0";
    ngx.header["Vary"]="Origin,Accept-Encoding";
    ngx.header["Content-Type"]="application/json;charset=UTF-8";
    --返回上游接口的响应体 body
    --返回上游接口的响应体 body
    return gcjson.encode(data);
end

--多个子请求
function goMultiUpstreams()
    local request_method = ngx.var.request_method
    local args = nil;
    local sendMethod = nil;
    --获取参数的值
    if "GET" == request_method then
        args = ngx.req.get_uri_args();
        sendMethod = ngx.HTTP_GET;
    elseif "POST" == request_method then
        ngx.req.read_body();
        args = ngx.req.get_post_args();
        sendMethod = ngx.HTTP_POST;
    end

    local postBody = ngx.encode_args({ post_k1 = 32, post_k2 = "post_v2" });
    local reqs = {};
    table.insert(reqs, { "/print_get_param", { args = "a=3&b=4" } });
    table.insert(reqs, { "/print_post_param", { method = ngx.sendMethod, args = args } });
    -- 统一发请求，然后等待结果
    local resps = { ngx.location.capture_multi(reqs) };

    -- 迭代结果列表
    for i, res in ipairs(resps) do
        ngx.say(" child res.status :", res.status, "<br>");
        ngx.say(" child  res.body :", res.body, "<br><br>");
    end
    ngx.req.set_header("Content-Type", "application/json;charset=utf8");
    ngx.req.set_header("Accept", "application/json");
    ngx.req.set_header("Accept-Encoding", "")
    --回源上游接口,比如Java 后端rest接口
    local resp = ngx.location.capture("/java/sku/detail", {
        sendMethod,
        args = args  -- 重要：将请求参数，原样向上游传递
    })
    basic:log("上游数据获取成功");
    --获取状态码
    ngx.status = resp.status;

    --获取响应头
    for k, v in pairs(resp.header) do
        if k ~= "Transfer-Encoding" and k ~= "Connection" then
            ngx.header[k] = v
        end
    end
    --返回上游接口的响应体 body
    return resp.body;
end

local cache = goUpstream();
ngx.say(cache);
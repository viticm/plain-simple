-- 链接
billing_pack_proto_t.reg_handler('connect', function(pack)

end)

-- 定时检测
billing_pack_proto_t.reg_handler('ping', function(pack)
  return {
    result = 1
  }
end)

-- 注册
billing_pack_proto_t.reg_handler('register', function(pack)

end)

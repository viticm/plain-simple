return {
    request = {
      {'username', 'string'},
      {'ip', 'string'},
      {'rolename', 'string'},
      {'order_id', 'raw', 21},
      {'goods_typenum', 'uint16'},
      {'goods_type', 'uint32'},
      {'goods_num', 'uint16'},
      {'need_point', 'uint32'},
    },
    response = {
      {'username', 'string'},
      {'order_id', 'raw'},
      {'result', 'uint8'},
      {'left_point', 'uint32'},
      {'goods_typenum', 'uint16'},
      {'goods_type', 'uint32'},
      {'goods_num', 'uint16'}
    },
    id = 0xe1,
}

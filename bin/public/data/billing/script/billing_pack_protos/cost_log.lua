return {
    request = {
      {'key', 'raw', 21},
      {'zone_id', 'uint16'},
      {'world_id', 'uint32'},
      {'server_id', 'uint32'},
      {'scene_id', 'uint32'},
      {'userid', 'uint32'},
      {'cost_time', 'uint32'},
      {'yuanbao', 'uint32'},
      {'username', 'string'},
      {'rolename', 'string'},
      {'rolelevel', 'uint16'},
      {'ip', 'string'},
    },
    response = {
      {'key', 'raw'},
      {'result', 'uint8'},
    },
    id = 0xc5,
}

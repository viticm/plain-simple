return {
    request = {
      {'username', 'string'},
      {'password', 'string'},
      {'ip', 'string'},
      {'rolelevel', 'uint16'},
      {'passenc', 'raw', 12},
      {'macmd5', 'raw', 32},
    },
    response = {
      {'username', 'string'},
      {'result', 'uint8'},
    },
    id = 0xa2,
}

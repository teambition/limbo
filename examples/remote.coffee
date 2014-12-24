limbo = require '../'
talkdb = limbo.use 'talk',
  provider: 'rpc'
  conn: 'tcp://localhost:7001'

talkdb.call 'user.findOne', name: 'Alice', (err, user) -> console.log 'find user Alice', user

# Description:
#   handles the 'markov'(room, seed) event
#
# Dependencies:
#   "hubot-markov": ""
#
# Configuration:
#   See configs array
#
# Commands:
#   None
#
Url = require 'url'
Redis = require '../node_modules/hubot-markov/node_modules/redis'

MarkovModel = require '../node_modules/hubot-markov/src/model'
RedisStorage = require '../node_modules/hubot-markov/src/redis-storage'

MarkovHook = (robot) ->
  # Configure redis the same way that redis-brain does.
  info = Url.parse process.env.REDISTOGO_URL or
    process.env.REDISCLOUD_URL or
    process.env.BOXEN_REDIS_URL or
    process.env.REDIS_URL or
    'redis://localhost:6379'
  client = Redis.createClient(info.port, info.hostname)

  if info.auth
    client.auth info.auth.split(":")[1]

  storage = new RedisStorage(client)

  # Read markov-specific configuration from the environment.
  ply = process.env.HUBOT_MARKOV_PLY or 1
  min = process.env.HUBOT_MARKOV_LEARN_MIN or 1
  max = process.env.HUBOT_MARKOV_GENERATE_MAX or 50

  model = new MarkovModel(storage, ply, min)

  MarkovHook.model = model

  robot.on 'markov', (room, seed) ->
    model.generate '', max, (text) =>
      robot.messageRoom "random", text

MarkovHook.generate = (seed, callback) =>
  MarkovHook.model.generate seed, process.env.HUBOT_MARKOV_GENERATE_MAX or 50, callback

module.exports = MarkovHook

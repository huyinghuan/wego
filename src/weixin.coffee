_url = require 'url'
_crypto = require 'crypto'
_xml2js = require 'xml2js'
events = require 'events'

emitter = new events.EventEmitter()

class Weixin
  ###
  # options object对象 ，包含对各类型消息处理的函数. 可选
  # parseError: function(err, buf){}  请看 parseErrorHandle
  # parseText, parseImage, parseVoice, parseVideo, parseLocation, parseLink
  # 以上这些函数 接收响应消息json对象
  # 如： parseText: function(message){...}
  ###
  contructor: (@options)->

  #消息合法性校验
  veritySignature: (req)->
    query = _url.parse(req.url, true).query
    #微信加密后的字符串
    signature = query['signature']
    #时间戳
    timestamp = query['timestamp']
    #随机数
    nonce = query['nonce']
    #随机字符串
    echostr = query['echostr']
    #数组
    arr = [token, timestamp, nonce]
    #排序转字符串
    str = arr.sort().join('')
    #创建hash生成器
    shasum = _crypto.createHash 'sha1'
    #hash编码
    shasum.update str
    #获取hash
    sha1 = shasum.digest('hex')
    #对比 返回
    sha1 is signature

  #事件监听
  initListener: ->
    self = @
    emitter.on 'weixin:parse:error', (e, msg, buf)->
      e.preventDefault()
      self.parseErrorHandle(msg, buf)

    msgTyps = ['text', 'image', 'voice', 'video', 'location', 'link']

    options = @options or {}

    #监听不同的消息类型
    for type in msgTyps
      emitter.on "weixin:parse:#{type}", (e, data)->
        e.preventDefault()
        #消息处理
        fn = options["parse#{type.charAt(0).toUpperCase()}#{type.substring(1)}"]
        fn data if self.isFunction(fn)

  #消息抽取
  parse: (req)->
    buf = ''
    req.on 'data', (chunk)->
      buf += chunk

    req.on 'end', ->
      _xml2js.parseString buf, (err, json)->
        return emitter.emit 'weixin:parse:error', err, buf if err
        xml = json.xml
        emitter.emit "weixin:parse:#{xml.MsgType}", xml



  #是否是函数 是否存在
  isFunction: (fn)->
    return typeof fn is 'function'

  #抽取消息时 发生错误时的处理
  ###
  # @err 抽取发生错误的事件
  # @buf 消息原文
  ###
  parseErrorHandle: (err, buf)->
    fn = @options.parseError
    fn err, buf if @isFunction(fn)

module.exports = Weixin
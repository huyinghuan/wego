_url = require 'url'
_crypto = require 'crypto'
_xml2js = require 'xml2js'
events = require 'events'

emitter = new events.EventEmitter()

class Weixin
  ###
  # token 微信token用于校验消息的合法性
  #
  # options object对象 ，包含对各类型消息处理的函数. 可选
  # parseError: function(err, buf){}  请看 parseErrorHandle
  # parseText, parseImage, parseVoice, parseVideo, parseLocation, parseLink
  # 以上这些函数 接收request, response ,响应消息json对象
  # 如： parseText: function(req, resp, message){...}
  ###
  constructor: (@token, @options)->

  #消息合法性校验
  veritySignature: (req)->
    params = _url.parse req.url, true
    query = params.query
    #微信加密后的字符串
    signature = query['signature']
    #时间戳
    timestamp = +query['timestamp']
    #随机数
    nonce = +query['nonce']
    #随机字符串
    echostr = query['echostr']
    #数组
    arr = [@token, timestamp, nonce]
    #排序转字符串
    str = arr.sort().join('')
    #创建hash生成器
    shasum = _crypto.createHash 'sha1'
    #hash编码
    shasum.update str
    #获取hash
    sha1 = shasum.digest('hex')
    #对比 返回
    echostr = echostr or true
    return echostr if sha1 is signature
    return false

  #消息抽取
  parse: (req, res)->
    self = @
    options = @options or {}

    buf = ''

    req.on 'data', (chunk)->
      buf += chunk

    req.on 'end', ->
      _xml2js.parseString buf, (err, json)->
        #处理解析错误
        if err
          req.weixin = error: err, data: buf
          return self.parseErrorHandle(req, res)

        xml = json.xml
        #数据绑定
        req.weixin = error: false, data: xml
        type = xml.MsgType[0]
        fnName = "parse#{type.charAt(0).toUpperCase()}#{type.substring(1)}"

        console.log 'fnName', fnName

        #对应消息处理函数选择
        fn = options[fnName]
        #处理消息
        return fn(req, res, xml) if self.isFunction(fn)
        #如果没有为相应的消息绑定事件,那么则使用默认时间接受数据
        self.defaultParseHanlde(req, res, xml)

  #是否是函数 是否存在
  isFunction: (fn)->
    return typeof fn is 'function'

  #抽取消息时 发生错误时的处理
  ###
  # @err 抽取发生错误的事件
  # @buf 消息原文
  ###
  parseErrorHandle: (req, resp)->
    fn = @options.parseError
    return fn req, resp if @isFunction(fn)
    @defaultParseHandle req, resp

  defaultParseHanlde: (req, res, data)->
    fn = @options.parseDefault

    #如果没有定义处理函数，则默认写回一个空字符串
    def = (req, res) ->
      res.send('')

    fn = if @isFunction(fn) then fn else def

    fn(req, res, data)

  sendText: ()->

  sendImage: ()->

  sendVoice: ()->

  sendVideo: ()->

  sendLocation: ()->

  sendLink: ()->

  sendMsg: ()->

module.exports = Weixin
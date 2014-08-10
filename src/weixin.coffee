_url = require 'url'
_crypto = require 'crypto'
class Weixin
  contructor: ->

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

module.exports = Weixin
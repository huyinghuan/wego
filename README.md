微信API的node实现
---------------

##Install
```shell
npm install wego
```

##Getting Started

假设你使用的是express框架

下面的代码是coffee写的。没有复杂的语法，直接脑补 括号就可以了

```coffeescript
#app.coffee

express = require 'express'
app = express()
port = 8000
token = "your token" #你的微信token

_WeGo = require 'wego' #引入wego

#引入不同消息类型处理的处理函数 具体见下面的 accept.coffee
acceptHandle = require '.accept'

wego = new _WeGo(token, acceptHandle) #进行基本设置。配置消息的处理事件等。

app.get('/', (req, res)->
  #进行消息验证 是否来自于微信
  #如果来自于微信,则返回来自于微信的一个随机字符串 echostr,
  #否则echostr为false
  echostr = wego.veritySignature(req)

  if echostr then res.send(echostr) else res.send('error')
)

app.post('/', (req, res)->
  #获取post数据 交给wego处理既可以
  wego.parse(req, res)
)

app.listen port
```

```coffeescript

# accept.coffee
_WeGo = require('wego')
wego = new _WeGo()
#一个object对象
Accept =
  #处理微信的文本消息
  parseText: (req, resp, data)->
    #用户发来的消息解析后，就在data参数里面。 当然，也绑定到了request的wego属性
    #即这里通过data 或者 req.wego.xml 都能获取到用户的数据
    console.log 'accept data:', data
    #返回消息的设定。这一部分可以写自己的业务逻辑。这里只是做个demo。返回的结果是"you say" + 用户发送过来的消息
    serverName = data.ToUserName
    clientName = data.FromUserName
    data.ToUserName = clientName
    data.FromUserName = serverName
    data.Content = "you say: #{data.Content}"

    #讲消息发送出去。
    #注意 data为微信消息xml数据格式 的json类型。 也就是把对应的标签换成相应的json属性即可。
    #注意 标签是大写 属性就大写，保持一致。
    wego.sendMsg(req, resp, data)

  #当来自于微信的xml数据无法解析时。会调用这个函数
  parseError: (req, resp)->
    console.log req.weixin.error
    console.log req.weixin.data
    resp.send ''

  #如果有消息类型没有设置自定义函数处理，则默认使用parseDefault这个函数进行处理
  parseDefault: (req, resp, data)->
    console.log "消息未处理"
    console.log data
    resp.send ''

module.exports = Accept
```
##API

### 构造函数 Wego

```js
Wego =  require('wego')
wego = new Wego(token, options)
```

#### token
微信的token。一般是开发者在微信公众平台自己设置的。

#### options
Object. 里面包含了一些 函数，用于对 不同消息类型进行处理

处理用户消息主要应该包括以下这几个字段函数：
```
  parseText, parseImage, parseVoice, parseVideo, parseLocation, parseLink
```
分别处理用户发来的文本消息，图片消息， 语音消息， 视频消息， 位置消息，和 超链接消息。
也就是说当wego在request中提取到用户消息时，根据不同的消息类型会调用以上的函数进行处理。
这些函数接收三个参数request, response, data。
```js
options = {
  parseText: function(request, response, data){

  },

  parseImage: function(){...}

  ...
}
```

request 即 http request. 解析后的数据会绑定在wego属性上：
```
console.log(request.wego)
```
response 即 http response

data. 解析后的数据除了会绑定到request上外 也会作为第三个参数data传过来，方便获取。


### 解析用户消息函数 parse

```ks
app.post('/', function(req, resp){
  wego.parse(req, resp)
})
```
接受两个参数 http request 和 http resposne
调用完成后就会结构初始化构造函数时的options里面的相关事件处理了。

### 发送消息 sendMsg
接收三个参数 http request 和 http resposne 还有响应消息的json数据 data
data为可选参数。 如果data存在则使用data中的数据。如果data不存在，则使用request.wego.xml中的数据
```
    #讲消息发送出去。
    #注意 data为微信消息xml数据格式 的json类型。 也就是把对应的标签换成相应的json属性即可。
    #注意 标签是大写 属性就大写，保持一致。
    wego.sendMsg(req, resp, data)
```
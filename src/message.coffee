
class Message
  constructor: ->


  getTextContent: (data)->
    "<Content><![CDATA[#{data.Content}]]></Content>"

  getImageContent: (data)->
    "<Image><MediaId><![CDATA[#{data.MediaId}]]></MediaId></Image>"

  getVoiceContent: (data)->
    "<Voice><MediaId><![CDATA[#{data.MediaId}]]></MediaId></Voice>"

  getVideoContent: (data)->
    "<Video>
        <MediaId><![CDATA[#{data.MediaId}]]></MediaId>
        <Title><![CDATA[#{data.Title}]]></Title>
        <Description><![CDATA[#{data.Description}]]></Description>
        </Video>"

  getMusicContent: (data)->
    "<Music>
        <Title><![CDATA[#{data.Title}]]></Title>
        <Description><![CDATA[#{data.Description}]]></Description>
        <MusicUrl><![CDATA[#{data.MusicUrl}]]></MusicUrl>
        <HQMusicUrl><![CDATA[#{data.HQMusicUrl}]]></HQMusicUrl>
        <ThumbMediaId><![CDATA[#{data.ThumbMediaId}]]></ThumbMediaId>
        </Music>"

  getNewsContent: (data)->
    articles = data.Articles
    articles = if articles.length > 10 then articles.splice(0, 10) else articles
    articlesConunt = "<ArticleCount>#{articles.length}</ArticleCount>"
    items = []
    for article in articles
      items.push "<item>
             <Title><![CDATA[#{article.Title}]]></Title><Description><![CDATA[#{article.Description}]]></Description>
            <PicUrl><![CDATA[#{article.PicUrl}]]></PicUrl> <Url><![CDATA[#{article.Url}]]></Url>
          </item>"

    "#{articlesConunt}<Articles>#{items.join('')}</Articles>"

  getContent: (data)->
    self = @
    type = data.MsgType
    fn = self["get#{type.charAt(0).toUpperCase()}#{type.substring(1)}Content"]
    msg = fn(data)
    time = Math.round(new Date().getTime() / 1000)
    "<xml>
      <ToUserName><![CDATA[#{data.ToUserName}]]></ToUserName>
      <FromUserName><![CDATA[#{data.FromUserName}]]></FromUserName>
      <CreateTime>#{time}</CreateTime>
      <MsgType><![CDATA[#{data.MsgType}]]></MsgType>
      #{msg}
      <FuncFlag>#{data.FuncFlag or 0}</FuncFlag>
    </xml>"

module.exports = new Message()
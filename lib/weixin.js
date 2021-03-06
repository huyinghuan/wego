// Generated by CoffeeScript 1.9.2
(function() {
  var Weixin, _crypto, _message, _url, _xml2js, events;

  _url = require('url');

  _crypto = require('crypto');

  _xml2js = require('xml2js');

  events = require('events');

  _message = require('./message');

  Weixin = (function() {

    /*
     * token 微信token用于校验消息的合法性
    #
     * options object对象 ，包含对各类型消息处理的函数. 可选
     * parseError: function(err, buf){}  请看 parseErrorHandle
     * parseText, parseImage, parseVoice, parseVideo, parseLocation, parseLink
     * 以上这些函数 接收request, response ,响应消息json对象
     * 如： parseText: function(req, resp, message){...}
     */
    function Weixin(token, options1) {
      this.token = token;
      this.options = options1;
    }

    Weixin.prototype.veritySignature = function(req) {
      var arr, echostr, nonce, params, query, sha1, shasum, signature, str, timestamp;
      params = _url.parse(req.url, true);
      query = params.query;
      signature = query['signature'];
      timestamp = +query['timestamp'];
      nonce = +query['nonce'];
      echostr = query['echostr'];
      arr = [this.token, timestamp, nonce];
      str = arr.sort().join('');
      shasum = _crypto.createHash('sha1');
      shasum.update(str);
      sha1 = shasum.digest('hex');
      echostr = echostr || true;
      if (sha1 === signature) {
        return echostr;
      }
      return false;
    };

    Weixin.prototype.parse = function(req, res) {
      var buf, options, self;
      self = this;
      options = this.options || {};
      buf = '';
      req.on('data', function(chunk) {
        return buf += chunk;
      });
      return req.on('end', function() {
        return _xml2js.parseString(buf, function(err, json) {
          var fn, fnName, key, ref, type, value, xml;
          if (err) {
            req.wego = {
              error: err,
              data: buf
            };
            return self.parseErrorHandle(req, res);
          }
          xml = {};
          ref = json.xml;
          for (key in ref) {
            value = ref[key];
            xml[key] = value[0];
          }
          req.wego = {
            error: false,
            data: xml
          };
          type = xml.MsgType;
          fnName = "parse" + (type.charAt(0).toUpperCase()) + (type.substring(1));
          fn = options[fnName];
          if (self.isFunction(fn)) {
            return fn(req, res, xml);
          }
          return self.defaultParseHanlde(req, res, xml);
        });
      });
    };

    Weixin.prototype.isFunction = function(fn) {
      return typeof fn === 'function';
    };


    /*
     * @err 抽取发生错误的事件
     * @buf 消息原文
     */

    Weixin.prototype.parseErrorHandle = function(req, resp) {
      var fn;
      fn = this.options.parseError;
      if (this.isFunction(fn)) {
        return fn(req, resp);
      }
      return this.defaultParseHandle(req, resp);
    };

    Weixin.prototype.defaultParseHanlde = function(req, res, data) {
      var def, fn;
      fn = this.options.parseDefault;
      def = function(req, res) {
        return res.send('');
      };
      fn = this.isFunction(fn) ? fn : def;
      return fn(req, res, data);
    };

    Weixin.prototype.sendMsg = function(req, resp, data) {
      var msg;
      resp.setHeader("Content-Type", "text/xml");
      data = data || req.wego.xml;
      msg = _message.getContent(data);
      return resp.end(msg);
    };

    return Weixin;

  })();

  module.exports = Weixin;

}).call(this);

# UDP.coffee
#
# (c) 2013 Dave Goehrig <dave@dloh.org>
# (c) 2014 wot.io LLC
#

udp = require 'dgram'

Udp = (Bridge, Url) ->
        self = this
        [ proto, host, port, domain, exchange, key, queue, dest, path, dhost, dport ] = Url.match(///([^:]+)://([^:]+):(\d+)/([^\/]*)/([^\/]*)/([^\/]*)/([^\/]*)/([^\/]*)/([^\/]*)/(\d+\.\d+\.\d+\.\d+)/(\d+)///)[1...] # "udp4", "dloh.org", "9966", //, "source-exchange", "source-key", "source-queue", "dest-exchange", "dest-key", "192.168.2.13", "6699"
        accountName = domain
        url = "/#{domain}/#{exchange}/#{key}/#{queue}/#{dest}/#{path}"
        monitoringExchange = 'monitoring-in'
        monitoringHashKey='#'

        self.getDate = () ->
        date = new Date()
        year = date.getFullYear()
        month = ("0" + (date.getMonth() + 1).toString()).substr(-2)
        day = ("0" + date.getDate().toString()).substr(-2)
        hour = ("0" + date.getHours().toString()).substr(-2)
        minute = ("0" + date.getMinutes().toString()).substr(-2)
        second = ("0" + date.getSeconds().toString()).substr(-2)
        formatedDate = "#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}"
        return formatedDate

        self.server = udp.createSocket 'udp4'
        self.server.bind port, host
        self.socket =  send : (message) ->
                self.server.send new Buffer(message), 0, message.length, dport, dhost, () ->
                        messageLength = message.length
                        writeConnection = '["wrote_connection", "'+url+'", "",  "' + accountName + '", "'+messageLength+'" ,"'+self.getDate()+'"]'
                        Bridge.send monitoringExchange, monitoringHashKey, writeConnection

        Bridge.connect domain, () ->
                Bridge.route exchange, key, queue
                Bridge.subscribe queue, self.socket, self.socket.send
        self.server.on 'message', (message, route) ->
                messageLength = message.length
                readConnection = '["read_connection", "'+url+'", "", "' + accountName + '", "'+messageLength+'", "'+self.getDate()+'"]'
                Bridge.send monitoringExchange, monitoringHashKey, readConnection
                Bridge.send dest, path, message

module.exports = Udp
~                      
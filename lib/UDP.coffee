# UDP.coffee
#
# (c) 2013 Dave Goehrig <dave@dloh.org>
# (c) 2014 wot.io LLC
#

udp = require 'dgram'

Udp = (Bridge, Url) ->
        self = this
        [ proto, host, port, domain, exchange, key, queue, dest, path, dhost, dport ] = Url.match(///([^:]+)://([^:]+):(\d+)/([^\/]*)/([^\/]*)/([^\/]*)/([^\/]*)/([^\/]*)/([^\/]*)/(\d+\.\d+\.\d+\.\d+)/(\d+)///)[1...] # "udp4", "dloh.org", "9966", //, "source-exchange", "source-key", "source-queue", "dest-exchange", "dest-key", "192.168.2.13", "6699"
        accountName = exchange
        self.server = udp.createSocket 'udp4'
        self.server.bind port, host
        self.socket =  send : (message) ->
                self.server.send new Buffer(message), 0, message.length, dport, dhost, () ->
                        messageLength = message.length
                        monitoringExchange = 'monitoring'
                        writeMessage = '["write_connection", "'+dhost+'", "",  "' + accountName + '", "'+messageLength+'" ,"'+new Date().getTime()+'"]'
                        Bridge.send monitoringExchange, '', writeMessage
                        console.log "Sent #{message} to #{dhost}:#{dport}"
        Bridge.connect domain, () ->
                Bridge.route exchange, key, queue
                Bridge.subscribe queue, self.socket, self.socket.send
        self.server.on 'message', (message, route) ->
                messageLength = message.length
                monitoringExchange = 'monitoring'
                console.log "#{route.address}"
                readMessage = '["read_connection" , "'+host+'" , "" , "' + accountName + '", "'+messageLength+'" ,"'+new Date().getTime()+'"]'
                console.log "Got #{message} from #{route.address}:#{route.port}"
                Bridge.send monitoringExchange, '', readMessage
                Bridge.send dest, path, message

module.exports = Udp
~                      
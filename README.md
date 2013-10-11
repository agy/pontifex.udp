pontifex.udp
============

A UDP to AMQP Bridge

Getting Started
---------------

You can install pontifex.udp from npm:

	npm install pontifex.udp

In one terminal start listening for UDP messages

	nc -l -4 -u 0.0.0.0 6699	# listen on port 6699

Run pontifex using a command like:

	pontifex 'udp://0.0.0.0:9966//udp-out/#/udp/udp-out/udp/127.0.0.1/6699' 'amqp://guest:guest@localhost:5672'

In other terminal send it:

	echo -n '[ "say", "hello world!" ]' | nc -u -4 -w 0 localhost 9966

This will take a message in on port 9966 put it onto the udp-out exchange with the key of udp, RabbitMQ will then route the message back to the bridge via the udp queue bound to the udp-out exchange with the wildcard # key. Once the bridge gets the AMQP message it sends it back out to localhost 6699.

Obviously, this is a totally madeup example, but you can use some imagination and figure out all sorts of interesting uses.




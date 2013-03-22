--[[
	this creates a listening server on the port specified in arg[1] (ie lua nonBlockSockets.lua <portnumber>)

	appears to be FASTER than nodeJS for socket communication, benchmark below (changed the exit command from "test" to "User-Agent: ApacheBench/2.3"):


	Nicks-iMac:bits nick$ ab -n 10000 -c 30 http://127.0.0.1:8080/
	This is ApacheBench, Version 2.3 <$Revision: 655654 $>
	...
	Concurrency Level:      30
	Time taken for tests:   0.949 seconds
	Complete requests:      10000
	Failed requests:        0
	Write errors:           0
	Total transferred:      250000 bytes
	Requests per second:    10532.64 [#/sec] (mean)
	Time per request:       2.848 [ms] (mean)
	Time per request:       0.095 [ms] (mean, across all concurrent requests)
	Transfer rate:          257.14 [Kbytes/sec] received

	Connection Times (ms)
	              min  mean[+/-sd] median   max
	Connect:        0    0   5.9      0     293
	Processing:     0    2  14.6      2     294
	Waiting:        0    2  13.7      2     294
	Total:          1    3  15.7      2     294

	Percentage of the requests served within a certain time (ms)
	  50%      2
	  66%      2
	  75%      2
	  80%      2
	  90%      2
	  95%      3
	  98%      4
	  99%      4
	 100%    294 (longest request)
]]

--get socket
local socket = require( 'socket' )

--create server
local server = socket.tcp()
server:bind( '*', arg[1] ) --arg1 of command line = bind port
server:settimeout( 0, 't' ) --no timeout - nonblocking
server:listen()

--init clients
local clients = {}

--loop
while true do
	--add any new clients
	local client = server:accept()
	--if we have a client, add them, do nothing else
	if client then
		client:settimeout( 0, 't' ) --set clients timeout
		table.insert( clients, { socket = client, data = {}, time = os.time() } )
		print( 'New connection from: ' .. client:getpeername() )
	end

	--loop clients, receive lines non-blockingly, add to client data 'buffer'
	for k, client in pairs( clients ) do
		local data = client.socket:receive( '*l' )
		--if no data assume timeout (no data in socket buffer to arrive)
		if data then
			--bump clients timeout
			client.time = os.time()
			table.insert( client.data, data )
		end
	end

	--reloop clients, process data
	for k, client in pairs( clients ) do
		if #client.data > 0 then
			--loop each line of client data
			for c, d in pairs( client.data ) do
				print( d ) --print for debug
				--if the client sends "test" we send back "hello world" and drop connection
				if d == 'User-Agent: ApacheBench/2.3' then
					client.socket:send( 'hello world\n' )
					client.ending = true
				end
				table.remove( client.data, c )
			end
		end

		--client socket removed?
		if client.ending or os.time() - client.time > 5 then
			client.socket:send( 'TIMEOUT! cya\n' )
			client.socket:close()
			table.remove( clients, k )
		end
	end

	--make sure if there's no connections we don't 100% a CPU core
	if #clients == 0 then
		server:settimeout( 30, 't' )
	else
		server:settimeout( 0, 't' )
	end
end
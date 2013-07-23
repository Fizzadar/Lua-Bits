#!/usr/bin/env lua

--[[
	usage: ./ipv4.lua 1.2.3.4/29

	output:
		Nicks-MacBook-Air:bits Fizzadar$ ./ipv4.lua 31.4.255.200/15
		###### INFO ######
		IP in: 31.4.255.200
		Mask in: /15
		=> Mask Wildcard: 0.1.255.255
		=> in IP is network-ip: false
		=> in IP is broadcast-ip: false

		###### BLOCK ######
		#IP's: 131072
		Bottom/Network: 31.4.0.0/15
		Top/Broadcast: 31.5.255.255
		Subnet Range: 31.4.0.0 - 31.5.255.255
		Host Range: 31.4.0.1 - 31.5.255.254

	confirmed/tested using:
		http://jodies.de/ipcalc
		http://www.subnet-calculator.com/cidr.php
]]
local tonumber, print = tonumber, print

--validate we have an ip
if not arg[1] then return print( 'invalid ip' ) end
--validate actual ip
local a, b, ip1, ip2, ip3, ip4, mask = arg[1]:find( '(%d+).(%d+).(%d+).(%d+)/(%d+)')
if not a then return print( 'invalid ip' ) end
local ip = { tonumber( ip1 ), tonumber( ip2 ), tonumber( ip3 ), tonumber( ip4 ) }

--list masks => wildcard
local masks = {
	[1] = { 127, 255, 255, 255 },
	[2] = { 63, 255, 255, 255 },
	[3] = { 31, 255, 255, 255 },
	[4] = { 15, 255, 255, 255 },
	[5] = { 7, 255, 255, 255 },
	[6] = { 3, 255, 255, 255 },
	[7] = { 1, 255, 255, 255 },
	[8] = { 0, 255, 255, 255 },
	[9] = { 0, 127, 255, 255 },
	[10] = { 0, 63, 255, 255 },
	[11] = { 0, 31, 255, 255 },
	[12] = { 0, 15, 255, 255 },
	[13] = { 0, 7, 255, 255 },
	[14] = { 0, 3, 255, 255 },
	[15] = { 0, 1, 255, 255 },
	[16] = { 0, 0, 255, 255 },
	[17] = { 0, 0, 127, 255 },
	[18] = { 0, 0, 63, 255 },
	[19] = { 0, 0, 31, 255 },
	[20] = { 0, 0, 15, 255 },
	[21] = { 0, 0, 7, 255 },
	[22] = { 0, 0, 3, 255 },
	[23] = { 0, 0, 1, 255 },
	[24] = { 0, 0, 0, 255 },
	[25] = { 0, 0, 0, 127 },
	[26] = { 0, 0, 0, 63 },
	[27] = { 0, 0, 0, 31 },
	[28] = { 0, 0, 0, 15 },
	[29] = { 0, 0, 0, 7 },
	[30] = { 0, 0, 0, 3 },
	[31] = { 0, 0, 0, 1 }
}

--get wildcard
local wildcard = masks[tonumber( mask )]

--number of ips in mask
local ipcount = math.pow( 2, ( 32 - mask ) )

--network IP (route/bottom IP)
local bottomip = {}
for k, v in pairs( ip ) do
	--wildcard = 0?
	if wildcard[k] == 0 then
		bottomip[k] = v
	elseif wildcard[k] == 255 then
		bottomip[k] = 0
	else
		local mod = v % ( wildcard[k] + 1 )
		bottomip[k] = v - mod
	end
end

--use network ip + wildcard to get top ip
local topip = {}
for k, v in pairs( bottomip ) do
	topip[k] = v + wildcard[k]
end

--is input ip = network ip?
local isnetworkip = ( ip[1] == bottomip[1] and ip[2] == bottomip[2] and ip[3] == bottomip[3] and ip[4] == bottomip[4] )
local isbroadcastip = ( ip[1] == topip[1] and ip[2] == topip[2] and ip[3] == topip[3] and ip[4] == topip[4] )

--output
print()
print( '###### INFO ######' )
print( 'IP in: ' .. ip[1] .. '.' .. ip[2] .. '.' .. ip[3] .. '.' .. ip[4]  )
print( 'Mask in: /' .. mask )
print( '=> Mask Wildcard: ' .. wildcard[1] .. '.' .. wildcard[2] .. '.' .. wildcard[3] .. '.' .. wildcard[4]  )
print( '=> in IP is network-ip: ' .. tostring( isnetworkip ) )
print( '=> in IP is broadcast-ip: ' .. tostring( isbroadcastip ) )

print( '\n###### BLOCK ######' )
print( '#IP\'s: ' .. ipcount )
print( 'Bottom/Network: ' .. bottomip[1] .. '.' .. bottomip[2] .. '.' .. bottomip[3] .. '.' .. bottomip[4] .. '/' .. mask )
print( 'Top/Broadcast: ' .. topip[1] .. '.' .. topip[2] .. '.' .. topip[3] .. '.' .. topip[4] )
print( 'Subnet Range: ' .. bottomip[1] .. '.' .. bottomip[2] .. '.' .. bottomip[3] .. '.' .. bottomip[4] .. ' - ' .. topip[1] .. '.' .. topip[2] .. '.' .. topip[3] .. '.' .. topip[4] )
print( 'Host Range: ' .. bottomip[1] .. '.' .. bottomip[2] .. '.' .. bottomip[3] .. '.' .. bottomip[4] + 1 .. ' - ' .. topip[1] .. '.' .. topip[2] .. '.' .. topip[3] .. '.' .. topip[4] - 1 )

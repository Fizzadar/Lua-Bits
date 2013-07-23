#!/usr/bin/env lua

--[[
	usage: ./ipv6.lua 2001:55c0:9168:2813::aef2/48

	output:
		Nicks-MacBook-Air:bits Fizzadar$ ./ipv6.lua 2001:55c0:9168:2813::aef2/48
		###### INFO ######
		IP in: 2001:55c0:9168:2813::aef2
		Mask in: /48
		=> Mask Wildcard: ffff:ffff:ffff:0000:0000:0000:0000:0000

		###### BLOCK ######
		#IP's: 1.2089258196146e+24
		Range Start: 2001:55c0:9168:0000:0000:0000:0000:0000
		Range End: 2001:55c0:9168:ffff:ffff:ffff:ffff:ffff

	confirmed/tested using:
		http://www.ipv6calculator.net/
]]
local tonumber, print = tonumber, print

--explode, credit: http://richard.warburton.it
function explode( string, divide )
  if divide == '' then return false end
  local pos, arr = 0, {}
  --for each divider found
  for st, sp in function() return string.find( string, divide, pos, true ) end do
    table.insert( arr, string.sub( string, pos, st - 1 ) ) --attach chars left of current divider
    pos = sp + 1 --jump past current divider
  end
  table.insert( arr, string.sub( string, pos ) ) -- Attach chars right of last divider
  return arr
end


--validate we have an ip
if not arg[1] then return print( 'invalid ip' ) end
--validate actual ip
local a, b, ip, mask = arg[1]:find( '([%w:]+)/(%d+)')
if not a then return print( 'invalid ip' ) end

--get ip bits
local ipbits = explode( ip, ':' )

--now to build an expanded ip
local zeroblock
for k, v in pairs( ipbits ) do
	--length 0? we're at the :: bit
	if v:len() == 0 then
		zeroblock = k

	--length not 0 but not 4, prepend 0's
	elseif v:len() < 4 then
		local padding = 4 - v:len()
		for i = 1, padding do
			ipbits[k] = 0 .. ipbits[k]
		end
	end
end
if zeroblock and #ipbits < 8 then
	--remove zeroblock
	ipbits[zeroblock] = '0000'
	local padding = 8 - #ipbits
	
	for i = 1, padding do
		table.insert( ipbits, zeroblock, '0000' )
	end
end

--generate wildcard from mask
local indent = mask / 4
local wildcardbits = {}
for i = 0, indent - 1 do
	table.insert( wildcardbits, 'f' )
end
for i = 0, 31 - indent do
	table.insert( wildcardbits, '0' )
end
--convert into 8 string array each w/ 4 chars
local count, index, wildcard = 1, 1, {}
for k, v in pairs( wildcardbits ) do
	if count > 4 then
		count = 1
		index = index + 1
	end
	if not wildcard[index] then wildcard[index] = '' end
	wildcard[index] = wildcard[index] .. v
	count = count + 1
end


--loop each letter in each ipbit group
local topip = {}
local bottomip = {}
for k, v in pairs( ipbits ) do
	local topbit = ''
	local bottombit = ''
	for i = 1, 4 do
		local wild = wildcard[k]:sub( i, i )
		local norm = v:sub( i, i )
		if wild == 'f' then
			topbit = topbit .. norm
			bottombit = bottombit .. norm
		else
			topbit = topbit .. '0'
			bottombit = bottombit .. 'f'
		end
	end
	topip[k] = topbit
	bottomip[k] = bottombit
end

--count ips in mask
local ipcount = math.pow( 2, 128 - mask )


--output
print()
print( '###### INFO ######' )
print( 'IP in: ' .. ip )
print( '=> Expanded IP: ' .. ipbits[1] .. ':' .. ipbits[2] .. ':' .. ipbits[3] .. ':' .. ipbits[4] .. ':' .. ipbits[5] .. ':' .. ipbits[6] .. ':' .. ipbits[7] .. ':' .. ipbits[8] )
print( 'Mask in: /' .. mask )
print( '=> Mask Wildcard: ' .. wildcard[1] .. ':' .. wildcard[2] .. ':' .. wildcard[3] .. ':' .. wildcard[4] .. ':' .. wildcard[5] .. ':' .. wildcard[6] .. ':' .. wildcard[7] .. ':' .. wildcard[8] )

print( '\n###### BLOCK ######' )
print( '#IP\'s: ' .. ipcount )
print( 'Range Start: ' .. topip[1] .. ':' .. topip[2] .. ':' .. topip[3] .. ':' .. topip[4] .. ':' .. topip[5] .. ':' .. topip[6] .. ':' .. topip[7] .. ':' .. topip[8] )
print( 'Range End: ' .. bottomip[1] .. ':' .. bottomip[2] .. ':' .. bottomip[3] .. ':' .. bottomip[4] .. ':' .. bottomip[5] .. ':' .. bottomip[6] .. ':' .. bottomip[7] .. ':' .. bottomip[8] )
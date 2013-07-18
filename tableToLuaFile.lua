#!/usr/bin/env lua

--[[
    turn a lua table into lua code
        function values are run and the result is written to string
]]
--turn a lua table into lua code
local function tableToLua( table, indent )
    indent = indent or 0
    local out = ''

    for k, v in pairs( table ) do
        out = out .. '\n'
        for i = 0, indent do
            out = out .. '\t'
        end
        if type( v ) == 'table' then
            if type( k ) == 'string' and k:find( '%.' ) then
                out = out .. '[\'' .. k .. '\'] = {' .. tableToLua( v, indent + 1 ) .. '\n'
            else
                out = out .. k .. ' = {' .. tableToLua( v, indent + 1 ) .. '\n'
            end
            for i = 0, indent do
                out = out .. '\t'
            end
            out = out .. '},'
        else
            if type( v ) == 'function' then v = tostring( v() ) end
            if type( v ) == 'string' then v = "'" .. v .. "'" end
            if type( v ) == 'boolean' then v = tostring( v ) end
            if type( k ) == 'number' then k = '' else k = k .. ' = ' end
            out = out .. k .. v .. ','
        end
    end
    out = out:sub( 0, out:len() - 1 )

    return '{' .. out .. '}'
end


--test it!
local _test = {
    test_table = { 'hi', lorem = ipsum },
    what = 'hi',
    'the',
    types = { 1, 'string', true, function() return 'iwasafunction' end }
}
print( '===========tableToLua( _test )' )
print( tableToLua( _test ) )

print( '===========now using string to create function' )
local _string = 'local table = ' .. tableToLua( _test ) .. ' return table'
print( _string )
local status, err = loadstring( _string )
if not status then error( err ) end
local status, result = pcall( status )
if not status then error( result ) end

print( '===========result of string function' )
print( result )
print( '===========tableToLua( result of string function ) (should be identical to above)' )
print( tableToLua( result ) )
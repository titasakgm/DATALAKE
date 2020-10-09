#!/usr/bin/ruby

require 'net/ping'

def up?(host)
    check = Net::Ping::External.new(host)
    check.ping?
end

chost = '192.168.50.20'
puts up?(chost) # prints "true" if ping replies

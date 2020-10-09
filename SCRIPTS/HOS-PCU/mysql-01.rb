#!/usr/bin/ruby

require 'mysql2'

con = Mysql2::Client.new(
  :host => "192.168.0.22",
  :username => "datalake",
  :password => "trang",
  :database => "hdc"
)
sql = "SELECT count(*) as count FROM person"
res = con.query(sql)
res.each do |rec|
  puts rec["count"]
end

#!/usr/bin/ruby

require 'rubygems'
require 'mysql2'

# count records from hdc
# input hcode and date

hcode = ARGV[0]
date = ARGV[1]
if date.nil?
  puts "usage: #{$0} <HCODE> <LAST DATE>\n"
  exit
end

con = Mysql2::Client.new(
  :host => "192.168.0.22",
  :username => "trang",
  :password => "datalake",
  :database => "hdc"
)

sql =<<EOS
SELECT CID as _id,
vhid as ccaattmm,
date_format(BIRTH,'%Y%m%d') as dob,
PID as pid,
HID as hid,
c.PRENAME as pre,
NAME as fname,
LNAME as lname,
HN as hn,
t.SEX as sex,
HOSPCODE as hcode,
TYPEAREA as typearea,
RACE as race,
NATION as nation,
RELIGION as religion,
EDUCATION as education,
date_format(D_UPDATE,'%Y%m%d') as updated_at
FROM t_person_cid t
LEFT OUTER JOIN cprename c ON (c.id_prename=t.PRENAME)
WHERE HOSPCODE="#{hcode}" AND date_format(D_UPDATE,'%Y%m%d') > '#{date}'
ORDER BY D_UPDATE,CID
EOS

res = con.query(sql)
res.each do |rec|
  puts rec
end

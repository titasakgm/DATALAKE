#!/usr/bin/ruby

#encoding: utf-8
require 'mysql2'

def save_person(s)
  # /home HAS 517GB
  fp = open("/home/hdc_data/person.txt","a")
  fp.write(s)
  fp.write("\n")
  fp.close
end

def padding(s)
  (0...13-s.length).each do |n|
    s = '0' + s
  end
  s
end

# HDC HOST: 192.168.0.22 (MySQL)
con = Mysql2::Client.new(
  :host => "192.168.0.22",
  :username => "trang",
  :password => "datalake",
  :database => "hdc"
)

# SET encoding utf8
sql = "SET character_set_results = 'utf8', character_set_client = 'utf8', character_set_connection = 'utf8', character_set_database = 'utf8', character_set_server = 'utf8'"
res = con.query(sql)

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
WHERE vhid LIKE '92%'
ORDER BY D_UPDATE,CID
EOS

res = con.query(sql)

n = 0
d = []
cid = nil

res.each do |rec|
  cid = padding(rec['_id'].to_s)
  d[0] = cid
  d[1] = rec['ccaattmm']
  d[2] = rec['dob']
  d[3] = rec['pid']
  d[4] = rec['hid']
  d[5] = rec['pre']
  d[6] = rec['fname']
  d[7] = rec['lname']
  d[8] = rec['hn']
  d[9] = rec['sex']
  d[10] = rec['hcode']
  d[11] = rec['typearea']
  d[12] = rec['race']
  d[13] = rec['nation']
  d[14] = rec['religion']
  d[15] = rec['education']
  d[16] = rec['updated_at'] || Time.now.strftime("%Y%m%d")

  save_person(d.join('|'))

  n += 1
  if n % 1000 == 0
    puts "#{Time.now.strftime("%H:%M:%S")}: #{n}"
  end 
end

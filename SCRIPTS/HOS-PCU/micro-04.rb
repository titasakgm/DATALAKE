#!/usr/bin/ruby

############################################
# SCRIPT: micro-04.rb
# DEVELOPER: drtoon
# DATE: 20200913
# PURPOSE: find CHANGE in D_UPDATE for HCODE
# OUTPUT: update mongodb:people FROM hdc
############################################

require 'json'

# find hcodes with CHANGED D_UPDATE
old = File.readlines('/tmp/MONGO-MAX-D-UPDATE', chomp: true)
new = File.readlines('/tmp/HDC-MAX-D-UPDATE', chomp: true)

# result will be Array
diff = new-old

array = []
diff.each do |kv|
  hcode = kv.split('|').first
  date = kv.split('|').last
  doc = {
    'hcode' => hcode,
    'updated_at' => date
  }
  array.push(doc)
end

resp = {
  'hcode' => nil,
  'updated_at' => nil
}

if array.count > 0
print <<EOF
Content-type: application/json

#{array.to_json}
EOF
else
print <<EOF
Content-type: application/json

[#{resp.to_json}]
EOF
end


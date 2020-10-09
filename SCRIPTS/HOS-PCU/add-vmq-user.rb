#!/usr/bin/ruby

require 'cgi'
require 'pty'
require 'expect'
require 'json'

c = CGI::new
user = c['user']

cmd  = "docker exec -uroot vmq0 vmq-passwd /etc/vernemq/vmq.passwd #{user}"

resp =<<EOF
Content-type: application/json

#{{'success': true}.to_json}
EOF

PTY.spawn(cmd) do |reader, writer|
  reader.expect(/Password:/,5) # cont. in 5s if input doesn't match
  writer.puts('datalake')
  reader.expect(/Reenter password:/,5) # cont. in 5s if input doesn't match
  writer.puts('datalake')

  puts resp
end


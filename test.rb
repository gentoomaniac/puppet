require 'rubygems'
require 'dnsruby'
include Dnsruby

# Use the system configured nameservers to run a query
res = Dnsruby::Resolver.new
ret = res.query("sto-coredns-a1.sto.gentoomaniac.net", Types.A)
print ret.answer

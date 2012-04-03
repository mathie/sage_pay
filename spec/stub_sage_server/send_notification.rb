require 'yaml'
require 'awesome_print'
require "net/http"
require "uri"
require 'sinatra'

name = File.expand_path("../post.yml", __FILE__)
yaml_obj = YAML::load(File.open(name))

ap yaml_obj.class
ap yaml_obj
ap yaml_obj.to_s

uri = URI.parse("http://127.0.0.1:80/sage_pay/notification")
http = Net::HTTP.new(uri.host, uri.port)

ap yaml_obj.params

request = Net::HTTP::Post.new(uri.request_uri)
request.set_form_data(yaml_obj)
response = http.request(request)
ap 'Response was ========'
ap response.body
ap 'exiting!'
exit

require 'sinatra'
require 'uri'
require 'mini_magick'
require 'open-uri'
require 'cgi'
require 'json'
require "net/http"
require "uri"
require 'typhoeus'

get '/' do
  erb :index
end

get '/btt' do
  content_type :json
  
  request = Typhoeus::Request.new(
    "http://api.appannie.com/v1/accounts/23929/apps/530942747/sales?start_date=2014-01-01&end_date=2014-03-01&break_down=date",
    method: :get,
    followlocation: true,
    headers: { 
      "Content-Type" => "application/json",
      "Authorization" => "bearer #{ENV['appannie_token']}"
             }
  )
  
  response = request.run
  
  json = JSON.parse(response.body)
  
  list = json["sales_list"]
  
  data = []
  list.each do |l|
    data << l["revenue"]["iap"]["sales"]
  end
  
  puts response
  puts json
  puts "==="
  JSON.pretty_generate(json)
  
  result = Hash.new
  result["item"] = data
  JSON.pretty_generate(result)
end
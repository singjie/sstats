require 'sinatra'
require 'uri'
require 'mini_magick'
require 'open-uri'
require 'cgi'
require 'json'
require "net/http"
require "uri"
require 'typhoeus'

def appannie_iap appid
  content_type :json
  
  today = DateTime.now
  last_month = today - 30
  
  today_string = today.strftime("%Y-%m-%d")
  last_month_string = last_month.strftime("%Y-%m-%d")
  
  url = "http://api.appannie.com/v1/accounts/23929/apps/#{appid}/sales?currency=SGD&start_date=#{last_month_string}&end_date=#{today_string}&break_down=date"
  
  puts url
  request = Typhoeus::Request.new(
    url,
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
  min = 999
  max = -999
  list.each do |l|
    iap = l["revenue"]["iap"]["sales"]
    data << iap
    
    iap_float = iap.to_f
    if iap_float > max
      puts "#{max} - #{iap_float}"
      max = iap_float
    end
    
    if iap_float < min
      puts "#{min} - #{iap_float}"
      min = iap_float
    end
  end
  
  result = Hash.new
  result["item"] = data
  settings = Hash.new
  settings["axisx"] = [last_month.strftime("%d/%m"), today.strftime("%d/%m")]
  settings["axisy"] = ["$#{min}", "$#{max}"]
  settings["colour"] = "ff9900"
  result["settings"] = settings
  JSON.pretty_generate(result)
end

get '/' do
  erb :index
end

get '/btt' do
  appannie_iap 530942747
end

get '/ftt' do
  appannie_iap 542975206
end
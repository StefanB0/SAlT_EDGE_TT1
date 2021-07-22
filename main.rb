require 'rest-client'
require 'json'
require 'rspec'
require 'watir'
require 'cgi'
require 'uri'
require 'base64'
require_relative 'lib/playlist.rb'
require_relative 'lib/track.rb'

# ! TEST FIXTURES
def request_authorization(scopes, email, password, browser_close)
  client_id = '41ea726de9ee48c5889b3bfaa1d7e050'
  client_secret = '73c79fb3753f4686bc2a4c86ecd2da80'
  redirect_uri = 'https://www.spotify.com'
  authorization_request = "https://accounts.spotify.com/authorize?" \
                        "client_id=#{client_id}&response_type=code&" \
                        "redirect_uri=#{redirect_uri}&scope="
  authorization_request += scopes.join('%20')
  b64_client_id = Base64.strict_encode64("#{client_id}:#{client_secret}")

  browser = Watir::Browser.start authorization_request

  if email && password
    browser.text_field(id: 'login-username').set email
    browser.text_field(id: 'login-password').set password
    2.times { browser.send_keys :tab }
    browser.send_keys :space
    browser.button(value: 'Log In').click
    if browser.button(value: 'Agree').present?
      browser.button(value: 'Agree').click
    end
  end

  i = 0
  until URI(browser.url).host == URI(redirect_uri).host
    sleep(1)
    i+=1
    break if i >= 300
  end
  if i >= 300
    abort("Runtime error, something went wrong")
  end

  au_code = CGI.parse(URI.parse(browser.url).query)['code'] [0]

  if browser_close
    browser.close
  end

  RestClient::Request.new({
    :method => :post,
    :url => 'https://accounts.spotify.com/api/token',
    :headers => { :accept => :json, :Authorization => "Basic #{b64_client_id}" },
    :payload => { :grant_type => 'authorization_code', :code => au_code, :redirect_uri => redirect_uri }
  }).execute do |response|
      JSON.parse(response.to_s)
  end

end

config_data = JSON.parse(File.read("config.json").to_s)

email = config_data['login']
password = config_data['password']
browser_close = config_data['browser_close']
reorder_data = config_data['reorder_data']
remove_index = config_data['remove_index']
song_collection = config_data['song_collection']
scopes = config_data['scopes']

token = request_authorization(scopes, email, password, browser_close)

auth_data = {
  :access_token => token['access_token'],
  :refresh_token => token['refresh_token'],
  :user_id => RestClient::Request.new({
    :method => :get,
    :url => 'https://api.spotify.com/v1/me',
    :headers => { :accept => :json, :content_type => 'application/json', :Authorization => "Bearer #{token['access_token']}"},
  }).execute do |response|
    JSON.parse(response.to_s)['id']
  end
}

playlist = Playlist.new
playlist.create_playlist(auth_data[:user_id], auth_data[:access_token], 'My new playlist', 'some awesome description')
playlist.song_add(auth_data[:access_token], song_collection)
playlist.reorder_playlist(auth_data[:access_token], reorder_data)
playlist.song_remove(auth_data[:access_token], remove_index)
File.write("database/out.json", playlist.to_json)



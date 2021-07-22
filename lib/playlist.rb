require 'json'
require_relative 'track.rb'

class Playlist

  def update(playlist_info)
    @id = playlist_info['id']
    @name = playlist_info['name']
    @description = playlist_info['description']
    @owner_name = playlist_info['owner']['display_name']
    @spotify_url = playlist_info['external_urls']['spotify']
    if playlist_info['tracks']['items'].empty?
      @tracks = []
    else
      @tracks = playlist_info['tracks']['items'].map { |el|
        Track.new(
          el['track']['id'],
          el['track']['name'],
          el['track']['artists'].map { |artist| artist['name'] },
          el['track']['album']['name'],
          el['track']['external_urls']['spotify'],
          el['track']['uri']
        )
      }
    end
    to_json
  end

  def id(id = @id)
    @id = id
  end

  def rewrite(id = @id, name = @name, description = @description, owner_name = @owner_name, spotify_url = @spotify_url, tracks = @tracks)
    @id = id
    @name = name
    @description = description
    @owner_name = owner_name
    @spotify_url = spotify_url
    @tracks = tracks
    to_json
  end

  def to_json
    JSON.pretty_generate(
      {
        :id => @id,
        :name => @name,
        :description => @description,
        :owner_name => @owner_name,
        :spotify_url => @spotify_url,
        :tracks => @tracks.empty? ? @tracks : @tracks.map { |track| JSON.parse(track.to_json) }
      }
    )
  end

  def get_playlist(access_token, id = @id)
    query = '?fields=id,name,description,owner(display_name),external_urls(spotify),tracks(items(track(album(name),id,uri,name,external_urls(spotify),artists(name))))'
    playlist_info = RestClient::Request.new({
      :method => :get,
      :url => "https://api.spotify.com/v1/playlists/#{id}#{query}",
      :headers => { :accept => :json, :Authorization => "Bearer #{access_token}" }
    }).execute do |response|
      JSON.parse(response.to_s)
    end
  end

  def create_playlist(user_id, access_token, playlist_name = 'Cool playlist', playlist_description = 'Automatically created playlist')
    playlist = RestClient::Request.new({
      :method => :post,
      :url => "https://api.spotify.com/v1/users/#{user_id}/playlists",
      :headers => {:content_type => 'application/json', :Authorization => "Bearer #{access_token}"},
      :payload => { :name => playlist_name, :description => playlist_description}.to_json
    }).execute do |response|
      response
    end
    @id = JSON.parse(playlist.to_s)['id']
    update(get_playlist(access_token))
    playlist.code
  end


  def song_add(access_token, song_collection)
    song_add = RestClient::Request.new({
      :method => :post,
      :url => "https://api.spotify.com/v1/playlists/#{@id}/tracks",
      :headers => { :Authorization => "Bearer #{access_token}", :params => {:uris => song_collection.join(',')}}
    }).execute do |response|
      response
    end
    update(get_playlist(access_token))
    song_add.code
  end

  def reorder_playlist(access_token, reorder_data)
    reorder = RestClient::Request.new({
      :method => :put,
      :url => "https://api.spotify.com/v1/playlists/#{@id}/tracks",
      :headers => { :Authorization => "Bearer #{access_token}"},
      :payload => {:range_start => reorder_data[0], :insert_before => reorder_data[1], :range_length => reorder_data[2]}.to_json
    }).execute do |response|
      response
    end
    update(get_playlist(access_token))
    reorder.code
  end

  def song_remove(access_token, remove_index)
    remove_list = remove_index.map { |index| { :uri => JSON.parse(@tracks[index].to_json)['uri'] } }
    remove = RestClient::Request.new({
      :method => :delete,
      :url => "https://api.spotify.com/v1/playlists/#{@id}/tracks",
      :headers => { :Authorization => "Bearer #{access_token}", :content_type => 'application/json'},
      :payload => {:tracks => remove_list}.to_json
    }).execute do |response|
      response
    end
    update(get_playlist(access_token))
    remove.code
  end

end

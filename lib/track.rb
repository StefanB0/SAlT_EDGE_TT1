require 'json'

class Track

  def initialize(id, name, artist_name, album_name, spotify_url, uri)
    @id = id
    @name = name
    @artist_name = artist_name
    @album_name = album_name
    @spotify_url = spotify_url
    @uri = uri
  end

  def to_json
    JSON.pretty_generate({
      :id => @id,
      :name => @name,
      :artist_name => @artist_name,
      :album_name => @album_name,
      :spotify_url => @spotify_url,
      :uri => @uri
    })
  end
end


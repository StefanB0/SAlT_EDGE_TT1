require 'playlist.rb'
require 'json'
require 'rest-client'

describe Playlist do

  let (:access_token) do
    'access token'
  end

  let (:dummy_playlist_id) do
    'playlist id'
  end

  let (:user_id) do
    'user id'
  end

  describe ".create_playlist" do

    context "given the user id and access token" do
      it "creates a playlist and returns the HTTP code 201" do
        expect(subject.create_playlist(user_id, access_token)).to eql(201)
      end
    end

    context "given the id, access token, name and description" do
      it "creates a playlist and returns the HTTP code 201" do
        expect(subject.create_playlist(user_id, access_token, 'Cool name', 'Very cool description')).to eql(201)
      end
    end
  end


  describe ".song_add" do
    context "given an access token and a valid list of song uris" do
      it "adds the song to the playlist and returns HTTP code 201" do
        subject.id(dummy_playlist_id)
        expect(subject.song_add(access_token, ["spotify:track:3M5d9IDIMCZYfSRxAr5Bti"])).to eql(201)
      end
    end
  end

  describe ".reorder_playlist" do
    context "given an access token and reorder indices" do
      it "reorders the playlist and returns HTTP code 201" do
        subject.id(dummy_playlist_id)
        expect(subject.reorder_playlist(access_token, [0, 3, 1])).to eql(200)
        subject.reorder_playlist(access_token, [2, 0, 1])
      end
    end
  end

  describe ".song_remove" do
    context "given an access token and removed song nr" do
      it "removes the song in that position" do
        subject.id(dummy_playlist_id)
        subject.update(subject.get_playlist(access_token))
        expect(subject.song_remove(access_token, [2])).to eql(200)
        subject.song_add(access_token, ["spotify:track:3M5d9IDIMCZYfSRxAr5Bti"])
      end
    end
  end
end

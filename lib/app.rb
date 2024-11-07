require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "sqlite3"

DB = SQLite3::Database.new(File.join(File.dirname(__FILE__), "db/jukebox.sqlite"))
DB.results_as_hash = true

get "/" do
  # TODO: Gather all artists to be displayed on home page
  query = "SELECT name, id FROM artists;"
  @artists = DB.execute(query).flatten
  erb :home # Will render views/home.erb file (embedded in layout.erb)
end

# Then:
# 1. Create an artist page with all the albums. Display genres as well
get "/artists/:id" do
  query = <<~SQL
    SELECT al.title, g.name, al.id FROM artists ar
    JOIN albums al ON al.artist_id = ar.id
    JOIN tracks t ON t.album_id = al.id
    JOIN genres g ON g.id = t.genre_id
    WHERE ar.id = ?
    GROUP BY al.title;
  SQL
  @result = DB.execute(query, params['id'])
  p @result
  erb :artist
end

get "/albums/:id" do
  query = <<~SQL
    SELECT t.name, t.id FROM tracks t
    JOIN albums a ON t.album_id = a.id
    WHERE a.id = ?
  SQL
  @tracks = DB.execute(query, params['id'])
  erb :album
end

get "/tracks/:id" do
  query = <<~SQL
    SELECT t.name, t.composer FROM tracks t
    WHERE t.id = ?
  SQL
  @track = DB.execute(query, params['id'])[0]
  erb :track
end

# 2. Create an album pages with all the tracks
# 3. Create a track page with all the track info

require('sinatra')
require('slim')
require('sqlite3')
require('bcrypt')

require_relative('endpoints/posts')
require_relative('endpoints/profiles')
require_relative('endpoints/users')

enable(:sessions)

db = SQLite3::Database.new("db/database2.db")
db.results_as_hash = true

get('/') do
    # Get profiles that the user is subscribed to,
    # then join those profiles by posts about any of those profiles

=begin
    SELECT *
    FROM posts as p
    WHERE p IN
        SELECT *
        FROM 
    
=end

    slim(:home)
end

# Tab in the top for a page 'Subscriptions' where you can CRD subscriptions
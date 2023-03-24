require('sinatra')
require('slim')
require('sqlite3')
require('bcrypt')

require_relative('endpoints/posts')
require_relative('endpoints/profiles')
require_relative('endpoints/users')

enable(:sessions)

get('/') do
    # Get profiles that the user is subscribed to,
    # then join those profiles by posts about any of those profiles

    posts = session[:user_id] != nil ? get_user_subscribed_posts(session[:user_id]) : []

    p posts

    slim(:home, locals:{posts: posts})
end

# Tab in the top for a page 'Subscriptions' where you can CRD subscriptions
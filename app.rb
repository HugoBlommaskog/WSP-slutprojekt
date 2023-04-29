require('sinatra')
require('slim')
require('sqlite3')
require('bcrypt')

require_relative('endpoints/posts')
require_relative('endpoints/profiles')
require_relative('endpoints/subscriptions')
require_relative('endpoints/users')

enable(:sessions)

include(Models)

# Display landing page
#
get('/') do
    # Get profiles that the user is subscribed to,
    # then join those profiles by posts about any of those profiles
    user_id = session[:user_id]
    posts = user_id != nil ? get_user_subscribed_posts(user_id) : []
    user_liked_post_ids = !posts.empty? ? get_user_liked_post_ids(user_id) : []

    for post in posts
        post_id = post["post_id"]
        user_liked = user_liked_post_ids.any?{|user_liked_post_id| user_liked_post_id["post_id"] == post_id}
        post["user_liked"] = user_liked
    end

    slim(:index, locals:{posts: posts})
end

# Tab in the top for a page 'Subscriptions' where you can CRD subscriptions
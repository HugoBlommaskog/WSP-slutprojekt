require_relative('../models.rb')

include(Model)

# Returns a page for creating a new post
get('/posts/new') do
    all_profiles = get_all_profiles()
    slim(:'posts/new', locals:{profiles: all_profiles})
end

# Creates a new post
#
# @param [Integer] profile_id, The ID of the profile that the post is about
# @param [String] message, The message of the post
post('/posts') do
    user_id = session[:user_id]
    profile_id = params[:profile_id]
    message = params[:message]

    puts "CREATING POST"
    puts profile_id
    puts message

    create_post(user_id, profile_id, message)

    redirect('/')
end

# Adds a like on a given post from a given user
#
# @param [Integer] :post_id, The ID of the post to like
post('/posts/:post_id/likes') do
    maybe_user_id = session[:user_id]

    if (maybe_user_id == nil)
        redirect('/')
    end

    post_id = params[:post_id]

    create_like(maybe_user_id, post_id)
end

# Removes a like on a given post from a given user
#
# @param [Integer] :post_id, The ID of the post to unlike
delete('/posts/:post_id/likes') do
    maybe_user_id = session[:user_id]

    if (maybe_user_id == nil)
        # User who isn't logged in called this endpoint
        puts "ERROR: User isn't logged in"
        redirect('/')
    end

    post_id = params[:post_id]

    delete_like(maybe_user_id, post_id)
end

# Remove a post
#
# @param [Integer] :post_id, The ID of the post to delete
post('/posts/:post_id/delete') do
    post_id = params[:post_id]
    maybe_user_id = session[:user_id]

    post_author = get_post_author(post_id)

    if (maybe_user_id != post_author)
        # Cannot delete a post unless the user made the post
        puts "ERROR: User[#{maybe_user_id}] tried to delete post by User[#{post_owner}]"
    end

    delete_post(post_id)
    
    redirect('/')
end

def all_of(*strings)
    return /(#{strings.join("|")})/
end

before all_of("/posts", "/posts/new", "/posts/:post_id/likes", "/posts/:post_id/delete") do
    # These operations require a signed-in user
    maybe_user_id = session[:user_id]
    if (maybe_user_id == nil)
        redirect('/')
    end
end
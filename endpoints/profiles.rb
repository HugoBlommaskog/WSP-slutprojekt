require_relative('../models.rb')

include(Models)

# Returns a page for creating a profile
get('/profiles/new') do
    slim(:'profiles/new')
end

# Creates a new profile (admin only)
#
# @param [String] name, The name of the new profile
post('/profiles') do
    profile_name = params[:name]
    maybe_user_id = session[:user_id]

    if (!is_valid_admin(maybe_user_id))
        # This endpoint requires a signed-in admin
        puts "ERROR: Failed to create profile - no admin signed in"
        redirect("/")
    end

    maybe_new_profile = create_profile(profile_name)

    if (maybe_new_profile == nil)
        # Error creating profile
        puts ("ERROR: Failed to create profile[#{profile_name}]")
        redirect('/')
    end

    redirect("/profiles/#{maybe_new_profile["profile_id"]}")
end

# Returns a page for searching for profiles
get('/profiles/search') do
    slim(:'profiles/search')
end

# Returns all profiles
#
# @param [String] name_search, The (optional) prefix to search by
get('/profiles') do
    puts "GET /profiles"
    maybe_name_search = params[:name_search]

    if (maybe_name_search == nil)
        # Not searching, just listing all
        profiles = get_all_profiles()
    else
        # Searching with a prefix
        profiles = search_profiles(maybe_name_search, session[:user_id])
    end

    slim(:'profiles/index', locals:{profiles: profiles, maybe_name_search: maybe_name_search})
end

# Returns information about a given profile
#
# @param [Integer] :profile_id, The ID of the profile
get('/profiles/:profile_id') do
    puts "Trying to retrieve profile"
    maybe_user_id = session[:user_id]
    profile_id = params[:profile_id]
    maybe_profile = get_profile(profile_id, maybe_user_id)

    if maybe_profile == nil
        # Bad ID
        puts "ERROR: Failed to find profile with ID #{profile_id}"
        redirect('/')
    end

    profile = maybe_profile
    profile_id = profile["profile_id"]

    user_subscribed = maybe_user_id != nil ? is_user_subscribed(maybe_user_id, profile_id) : false
    posts = get_posts_about_profile(profile["profile_id"])

    user_liked_post_ids = !posts.empty? ? get_user_liked_post_ids(maybe_user_id) : []

    for post in posts
        post_id = post["post_id"]
        user_liked = user_liked_post_ids.any?{|user_liked_post_id| user_liked_post_id["post_id"] == post_id}
        post["user_liked"] = user_liked
    end

    $profile_id = profile_id
    slim(:'profiles/show', locals:{profile_name: profile["name"], profile_id: profile_id, profile_active: maybe_profile["active"], posts: posts, user_subscribed: user_subscribed})
end

# Activates a given profile
#
# @param [Integer] :profile_id, The ID of the profile to activate
post('/profiles/:profile_id/activate') do
    maybe_user_id = session[:user_id]

    if (!is_valid_admin(maybe_user_id))
        puts "ERROR: Failed to activate profile - no admin signed in"
        redirect('/')
    end

    profile_id = params[:profile_id]
    activate_profile(profile_id)

    puts "LOG: Profile[#{profile_id}] has been activated"

    redirect("/profiles/#{profile_id}")
end

# Deactivates a given profile
#
# @param [Integer] :profile_id, The ID of the profile to deactivate
post('/profiles/:profile_id/deactivate') do
    maybe_user_id = session[:user_id]

    if (!is_valid_admin(maybe_user_id))
        puts "ERROR: Failed to deactivate profile - no admin signed in"
        redirect('/')
    end

    profile_id = params[:profile_id]
    deactivate_profile(profile_id)

    puts "LOG: Profile[#{profile_id}] has been activated"

    redirect("/profiles/#{profile_id}")
end
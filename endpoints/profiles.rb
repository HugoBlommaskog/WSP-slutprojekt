require_relative('../utils.rb')

# Create

# Retrieve the page for creating a profile
get('/profiles/create') do
    slim(:'create-profile')
end

# Create a new profile
post('/profiles') do
    profile_name = params[:name]

    maybe_user_id = session[:user_id]
    

    maybe_new_profile = create_profile(profile_name)

    if maybe_new_profile == nil
        # Error creating profile (duplicate I suppose)
        puts ("Error creating profile [#{profile_name}]")
        redirect('/')
    end

    redirect("/profiles/#{maybe_new_profile["profile_id"]}")
end

# Read

# Retrieve the page for searching for profiles
get('/profiles/search') do
    slim(:search_profiles)
end

# Retrieve all profiles, potential name search
get('/profiles') do
    puts "GET /profiles"
    maybe_name_search = params[:name_search]
    puts maybe_name_search

    if maybe_name_search == nil
        # Not searching, just listing all
        profiles = get_all_profiles()
    else
        # Searching with a prefix
        profiles = search_profiles(maybe_name_search)
    end

    slim(:profiles, locals:{profiles: profiles, maybe_name_search: maybe_name_search})
end

# Retrieve information about a profile
get('/profiles/:profile_id') do
    puts "Trying to retrieve profile"
    maybe_profile = get_profile(params[:profile_id])

    if maybe_profile == nil
        # Bad ID
        redirect('/')
    end

    profile = maybe_profile

    user_subscribed = session[:user_id] != nil ? is_user_subscribed(session[:user_id], profile["profile_id"]) : false
    puts "User subscribed: #{user_subscribed}"
    posts = get_posts_about_profile(profile["profile_id"])
    $profile_id = maybe_profile["profile_id"]
    slim(:profile, locals:{profile_name: maybe_profile["name"], profile_id: maybe_profile["profile_id"], posts: posts, user_subscribed: user_subscribed})
end

# Subscribe to a profile
post('/subscriptions') do
    puts "POST /subscriptions"
    profile_id = params[:profile_id]
    puts "Subscribing to profile #{profile_id}"
    # Get user from session
    # Check if user is subscribed - if so, return
    # Subscribe

    created_subscription_id = create_subscription(session[:user_id], profile_id)

    puts "Created subscription with ID #{created_subscription_id}"

    p is_user_subscribed(session[:user_id], profile_id)

    redirect("/profiles/#{profile_id}")
end

post('/subscriptions/delete') do
    puts "Deleting subscription"
    profile_id = params[:profile_id]

    delete_subscription(session[:user_id], profile_id)

    redirect("/profiles/#{profile_id}")
end

# Admin

# Create a profile (admin?)
post('/profiles') do
    # Check if profile exists by name - if so, 400 bad request
end
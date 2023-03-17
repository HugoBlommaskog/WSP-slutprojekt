require_relative('../utils.rb')

# Create

# Retrieve the page for creating a profile
get('/profiles/create') do
    slim(:'create-profile')
end

# Create a new profile
post('/profiles') do
    profile_name = params[:name]

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

    posts = get_posts_about_profile(profile["profile_id"])
    $profile_id = maybe_profile["profile_id"]
    slim(:profile, locals:{profile_name: maybe_profile["name"], profile_id: maybe_profile["profile_id"], posts: posts})
end

# Subscribe to a profile
post('/subscriptions') do
    # Get user from session
    # Check if user is subscribed - if so, return
    # Subscribe
end

# Admin

# Create a profile (admin?)
post('/profiles') do
    # Check if profile exists by name - if so, 400 bad request
end
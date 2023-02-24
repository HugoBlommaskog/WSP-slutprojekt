require_relative('../utils.rb')
require_relative('../models.rb')

# Create

# Retrieve the page for creating a post
get('/posts/create') do
    all_profiles = get_all_profiles()
    puts "All profiles:"
    p all_profiles
    slim(:create_post, locals:{profiles: all_profiles})
end

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
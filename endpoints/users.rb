require_relative('../models.rb')

include(Models)

# Returns a page for creating a new user
get('/users/new') do
    slim(:register)
end

# Creates a new user
#
# @param [String] username, The username of the new user
# @param [String] password, The password of the new user
post('/users') do
    username = params[:username]
    password = params[:password]
    
    puts "LOG: Creating user with username '#{username}' and password '#{password}'"

    created_user = register(username, password)

    if (created_user != nil)
        # Successfully created a new user
        session[:user_id] = created_user["user_id"]
        session[:username] = created_user["username"]
    else
        # Something went wrong
        puts "ERROR: Failed to create user"
    end

    redirect('/')
end

# Returns a page for loggin in
get('/users/login') do
    puts "RETRIEVING PAGE FOR LOGGING IN"
    slim(:'users/login')
end

# Returns a page for logging out
get('/users/logout') do
    slim(:'users/logout')
end

# Logs a user in
#
# @param [String] username, The username of the user to log into
# @param [String] password, The password of the user to log into
post('/users/login') do
    username = params[:username]
    password = params[:password]

    maybe_logged_in_user = login(username, password)

    if (maybe_logged_in_user != nil)
        user = maybe_logged_in_user
        session[:user_id] = user["user_id"]
        session[:username] = user["username"]
    else
        # Something went wrong with the log-in
        puts "ERROR: Failed to log in"
    end

    redirect('/')
end

# Logs a user out
post('/users/logout') do
    session[:user_id] = nil
    session[:username] = nil
    
    redirect('/')
end
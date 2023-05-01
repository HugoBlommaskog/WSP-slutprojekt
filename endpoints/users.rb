require_relative('../model.rb')

include(Model)

# Returns a page for creating a new user
get('/users/new') do
    slim(:'users/new')
end

# Creates a new user
#
# @param [String] username, The username of the new user
# @param [String] password, The password of the new user
post('/users') do
    username = params[:username]
    password = params[:password]

    if (user_exists_by_username(username))
        # Cannot create a user with this username since it's taken
        error_message = "ERROR: Failed to create user - user with username [#{username}] already exists"
        puts(error_message)
        flash[:notice] = error_message
        redirect('/users/new')
    end

    created_user = register(username, password)

    if (created_user != nil)
        # Successfully created a new user
        session[:user_id] = created_user["user_id"]
        session[:username] = created_user["username"]

        puts("LOG: Created User[ID=#{created_user["user_id"]}, username=#{created_user["username"]}]")
    else
        # Something went wrong (This shouldn't happen)
        puts("ERROR: Failed to create user")
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

    maybe_user_by_username = find_user_by_username(username)

    if (maybe_user_by_username == nil)
        error_message = "ERROR: Failed to log in - No user exists with username [#{username}]"
        puts(error_message)
        flash[:notice] = error_message

        redirect('/users/login')
    end

    user = maybe_user_by_username

    successful_login = login(user, password)

    if (!successful_login)
        error_message = "ERROR: Incorrect password [#{password}] for user [#{username}]"
        puts(error_message)
        flash[:notice] = error_message

        redirect('/users/login')
    end

    session[:user_id] = user["user_id"]
    session[:username] = user["username"]

    redirect('/')
end

# Logs a user out
post('/users/logout') do
    session[:user_id] = nil
    session[:username] = nil
    
    redirect('/')
end
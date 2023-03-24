require_relative('../models.rb')
require_relative('../utils.rb')

# Create

# Retrieve the page for creating a new user
get('/users/register') do
    slim(:register)
end

# Create a new user
post('/users') do
    username = params[:username]
    password = params[:password]
    
    puts "Creating user with username '#{username}' and password '#{password}'"

    created_user = register(username, password)

    if (created_user != nil)
        # Successfully created a new user
        session[:user_id] = created_user["user_id"]
        session[:username] = created_user["username"]
        redirect('/')
    else
        # Something went wrong
        return "Something went wrong"
    end
end

# Read

# Update

# Retrieve the page for logging in
get('/users/login') do
    puts "RETRIEVING PAGE FOR LOGGING IN"
    slim(:login)
end

# Retrieve the page for logging out
get('/users/logout') do
    slim(:logout)
end

# Retrieve a user's profile
# This should be under read, but /:user_id has to be declared after /login and /logout
get('/users/:user_id') do
    #
end

# Logs a user in
post('/users/login') do
    puts "TRYING TO LOG IN"

    username = params[:username]
    password = params[:password]

    logged_in_user = login(username, password)

    if (logged_in_user != nil)
        session[:user_id] = logged_in_user["user_id"]
        session[:username] = logged_in_user["username"]
    end

    redirect('/')
end

# Logs a user out
post('/users/logout') do
    session[:user_id] = nil
    session[:username] = nil
    
    redirect('/')
end 

#Update a user's profile (only username, right?)
post('/users/:user_id') do
    # Get user_id from users in DB that have the wanted name, if id != :user_id reject on 400 bad request 
end

# Delete

# Delete a user (admin)
post('/users/:user_id/delete') do
   # 
end

# Login
post('users') do
    # Redirect to home (if success, otherwise same page with fail message)
end

# Admin - do validation before any functionality

# Admin only?
get('/users') do
   return "Hello users!" 
end
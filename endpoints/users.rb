require_relative('../models.rb')
require_relative('../utils.rb')

# Create

# Retrieve the page for creating a new user
get('/users/register') do
    slim(:register)
end

# Retrieve the page for logging in
get('/users/login') do
    slim(:login)
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

# Retrieve a user's profile
get('/users/:user_id') do
    #
end

# Update
post('/users/login') do
    puts "TRYING TO LOG IN"
    redirect('/')
end

# Logs a user out. This shouldn't be a GET method smh
get('/users/logout') do
    session[:user_id] = nil
    session[:username] = nil
    
    slim(:home)
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
require_relative('models.rb')
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
    # Wohoo
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
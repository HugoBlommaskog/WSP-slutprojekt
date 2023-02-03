require_relative('../utils.rb')

# Create

# Read

# Retrieve all profiles
get('/profiles/search') do

end

# Retrieve information about a profile
get('/profiles/:profile_id') do

end

# Subscribe to a profile
post('/profiles/:profile_id/subscribe') do
    # Get user from session
    # Check if user is subscribed - if so, return
    # Subscribe
end

# Admin

# Retrieve the page for creating a new profile
get('/new-profile') do
    # slim(whatever)
end

# Create a profile (admin?)
post('/profiles') do
    # Check if profile exists by name - if so, 400 bad request
end
require_relative('../models.rb')

include(Model)

# Creates a subscription to a given profile for the signed-in user
#
# @param [Integer] profile_id, The ID of the profile to subscribe to
post('/subscriptions') do
    profile_id = params[:profile_id]
    maybe_user_id = session[:user_id]

    if (is_user_subscribed(maybe_user_id, profile_id))
        # User is already subscribed
        puts "ERROR: User is already subscribed"
        redirect('/')
    end

    created_subscription_id = create_subscription(session[:user_id], profile_id)

    puts "LOG: Created subscription[#{created_subscription_id}]"

    redirect("/profiles/#{profile_id}")
end

# Deletes a subscription to a given profile for the signed-in user
#
# @param [Integer] profile_id, The ID of the profile to unsubscribe to
post('/subscriptions/delete') do
    profile_id = params[:profile_id]
    maybe_user_id = session[:user_id]

    delete_subscription(maybe_user_id, profile_id)

    redirect("/profiles/#{profile_id}")
end
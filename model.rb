require('sqlite3')
require('bcrypt')
require('sinatra/flash')

module Model

    # Helper function to create a database connection and configure it
    #
    # @return [SQLite3::Database] The object representing the database connection
    def get_db()
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        return db
    end

    # Attempts to register a user
    #
    # @param [String] username, The username of the new user
    # @param [String] password, The password of the new user
    #
    # @return [Hash] A hash map representing the newly created DB user entity
    def register(username, password)
        db = get_db()

        password_digest = BCrypt::Password.create(password)

        db.execute("
            INSERT INTO users (username, password_hash) 
            VALUES (?, ?)", username, password_digest)

        created_user_id = db.last_insert_row_id()
        created_user = db.execute("
            SELECT * FROM users 
            WHERE user_id = ?", 
            created_user_id).first

        return created_user
    end

    # Checks whether a user already exists by a given username
    #
    # @param [String] username, The username
    #
    # @return [Boolean] Whether a user exists by that username
    def user_exists_by_username(username)
        db = get_db()

        existing_users_with_username = db.execute("
            SELECT 1 FROM users
            WHERE username = ?",
            username)

        return !existing_users_with_username.empty?
    end

    # Attempts to log into a user account
    #
    # @param [Hash] user, The DB user entity to log into
    # @param [String] password, The password of the user to log into
    #
    # @return [Boolean] Whether the login was successful (correct password)
    def login(user, password)
        password_digest = user["password_hash"]

        # Check that the password is the correct one for the user
        if (BCrypt::Password.new(password_digest) != password)
            # Incorrect password, create a cooldown to avoid frequent brute-force requests
            sleep(3)
            return false
        end

        return true
    end

    # Attempts to find a user by a given username
    #
    # @param [String] username, The username to search by
    #
    # @return [Hash] A hash map representing the DB user entity,
    # or nil if no user was found
    def find_user_by_username(username)
        users = get_db().execute("
            SELECT * FROM users
            WHERE username = ?",
            username)

        return (users.empty?) ? nil : users.first()
    end

    # Attempts to create a profile
    #
    # @param [String] profile_name, The name of the new profile
    #
    # @return [Hash] A hash map representing the newly created DB profile entity,
    # or nil if the profile name is already taken
    def create_profile(profile_name)
        db = get_db()

        db.execute(
            "INSERT INTO profiles (name) 
                VALUES (?)",
            profile_name)

        created_profile_id = db.last_insert_row_id()
        created_profile = db.execute("
            SELECT * FROM profiles 
            WHERE profile_id = ?", 
            created_profile_id).first

        puts("LOG: Created Profile[ID=#{created_profile_id}, name=#{created_profile["name"]}]")

        return created_profile
    end

    # Checks whether a profile exists by the given name
    #
    # @param [String] profile_name, The name to find profiles by
    #
    # @return [Boolean] Whether a profile exists by that name
    def profile_exists_by_name(profile_name)
        db = get_db()

        existing_profiles_with_name = db.execute("
            SELECT 1 FROM profiles
            WHERE name = ?",
            profile_name)

        return !existing_profiles_with_name.empty?
    end

    # Attempts to retrieve information about a profile
    #
    # @param [Integer] profile_id, The ID of the profile to look up
    # @param [Integer] maybe_user_id, The (potential) ID of the user doing the lookup
    #
    # @return [Hash] A hash map representing the DB entity of the retrieved profile,
    # or nil if no profile was found/available by the given ID
    def get_profile(profile_id, maybe_user_id)
        if (is_valid_admin(maybe_user_id))
            # Find among ALL profiles, since a logged-in admin can see everything
            profiles = get_db().execute("
                SELECT * FROM profiles
                WHERE profile_id = ?",
                profile_id)
        else
            # Find among ACTIVE profiles, since a non-admin cannot see deactivated profiles
            profiles = get_db().execute("
                SELECT * FROM profiles
                WHERE profile_id = ? AND active = 1",
                profile_id)
        end

        return (profiles.empty?) ? nil : profiles.first()
    end

    # Returns information about all available profiles
    #
    # @return [Array] An array containing hash map representations of all available DB profile entities
    def get_all_profiles()
        return get_db().execute("
            SELECT * FROM profiles
            WHERE profiles.active = 1")
    end

    # Returns all profiles whose name match the given prefix
    #
    # @param [String] prefix, The prefix of the profile names to find
    #
    # @return [Array] An array containing hash map representations of all available 
    # DB profile entities matching the given prefix
    def search_profiles(prefix, maybe_user_id)
        if (is_valid_admin(maybe_user_id))
            # Find among ALL profiles, since a logged-in admin can see everything
            profiles = get_db().execute("
                SELECT * FROM profiles
                WHERE profiles.name LIKE '#{prefix}%'")
        else
            # Find among ACTIVE profiles, since a non-admin cannot see deactivated profiles
            profiles = get_db().execute("
                SELECT * FROM profiles
                WHERE profiles.name LIKE '#{prefix}%' AND profiles.active = 1")
        end

        # Yes, I know using #{prefix} in SQL is bad but it doesn't work with the ? injection

        return profiles
    end

    # Creates a post
    #
    # @param [Integer] user_id, The ID of the user who creates the post
    # @param [Integer] profile_id, The ID of the profile that the post is about
    # @param [String] message, The message of the post
    #
    # @return [Integer] The ID of the newly created post
    def create_post(user_id, profile_id, message)
        db = get_db()

        db.execute("
            INSERT INTO posts (user_id, profile_id, message)
            VALUES(?, ?, ?)",
            user_id,
            profile_id,
            message)

        created_post_id = db.last_insert_row_id()

        return created_post_id
    end

    # Retrieves all posts about a profile
    #
    # @param [Integer] profile_id, The ID of the profile about whom the posts should be
    #
    # @return [Array] An array of hashes representing the posts about that profile
    def get_posts_about_profile(profile_id)
        db = get_db()
        posts = db.execute("
            SELECT posts.post_id            AS post_id,
                   posts.user_id            AS author_id,
                   posts.profile_id         AS profile_id,
                   posts.message            AS message,
                   author.username          AS username,
                   profiles.name            AS profile_name,
                   COUNT(likes.like_id)     AS like_count
            FROM posts
            INNER JOIN profiles ON posts.profile_id = profiles.profile_id AND profiles.profile_id = ?
            INNER JOIN users AS author ON posts.user_id = author.user_id
            LEFT JOIN likes ON posts.post_id = likes.post_id
            GROUP BY posts.post_id",
            profile_id)
        
        return posts
    end

    # Creates a subscription on a profile for a user
    #
    # @param [Integer] user_id, The ID of the user who subscribes
    # @param [Integer] profile_id, The ID of the profile that the 
    # user is to be subscribed to
    #
    # @return [Integer] The ID of the newly created subscription
    def create_subscription(user_id, profile_id)
        db = get_db()
        db.execute("
            INSERT INTO subscriptions (user_id, profile_id) VALUES (?, ?)",
            user_id,
            profile_id)

        created_subscription_id = db.last_insert_row_id()

        return created_subscription_id
    end

    # Checks whether a user is subscribed to a profile
    #
    # @param [Integer] user_id, The ID of the user
    # @param [Integer] profile_id, The ID of the profile
    #
    # @return [Boolean] Whether the user is subscribed to the profile
    def is_user_subscribed(user_id, profile_id)
        return (user_id != nil) && !get_db()
            .execute("
                SELECT 1 FROM subscriptions
                WHERE user_id = ? AND profile_id = ?",
                user_id, profile_id).empty?
    end

    # Deletes a subscription on a profile for a user
    #
    # @param [Integer] user_id, The ID of the user who subscribes
    # @param [Integer] profile_id, The ID of the profile that the 
    # user is subscribed to
    def delete_subscription(user_id, profile_id)
        get_db()
            .execute("
                DELETE FROM subscriptions
                WHERE user_id = ? AND profile_id = ?",
                user_id,
                profile_id)
    end

    # Returns all posts about profiles that the given user is subscribed to
    #
    # @param [Integer] user_id, The ID of the user
    #
    # @return [Array] An array of hashes representing the posts about
    # the subscribed-to profiles
    def get_user_subscribed_posts(user_id)
        db = get_db()
        posts = db
            .execute("
                SELECT posts.post_id            AS post_id, 
                       posts.user_id            AS author_id, 
                       posts.profile_id         AS profile_id, 
                       posts.message            AS message, 
                       author.username          AS username, 
                       profiles.name            AS profile_name, 
                       COUNT(likes.like_id)     AS like_count
                FROM posts
                INNER JOIN subscriptions ON subscriptions.profile_id = posts.profile_id AND subscriptions.user_id = ?
                INNER JOIN profiles ON posts.profile_id = profiles.profile_id AND profiles.active = 1
                INNER JOIN users AS author ON posts.user_id = author.user_id
                LEFT JOIN likes ON posts.post_id = likes.post_id
                GROUP BY posts.post_id",
                user_id
            )

        return posts
    end

    # Returns the IDs of all posts that a given user has liked
    #
    # @param [Integer] user_id, The ID of the user
    #
    # @return [Array] An array of the IDs
    def get_user_liked_post_ids(user_id)
        post_ids = get_db()
            .execute("
                SELECT DISTINCT posts.post_id
                FROM posts
                INNER JOIN likes ON posts.post_id = likes.post_id AND likes.user_id = ?",
                user_id
            )

        return post_ids
    end

    # Creates a like on a post for a user
    #
    # @param [Integer] user_id, The user who has liked the post
    # @param [Integer] post_id, The ID of the liked post
    def create_like(user_id, post_id)
        get_db()
            .execute(
                "INSERT INTO likes (user_id, post_id) VALUES (?, ?)",
                user_id,
                post_id)
    end

    # Deletes a like on a post for a user
    #
    # @param [Integer] user_id, The ID of the user who has unliked the post
    # @param [Integer] post_id, The ID of the unliked post
    def delete_like(user_id, post_id)
        get_db()
            .execute(
                "DELETE FROM likes
                    WHERE user_id = ? AND post_id = ?",
                user_id,
                post_id)
    end

    # Activates a profile such that it can be viewed publicly
    #
    # @param [Integer] profile_id, The ID of the profile to activate
    def activate_profile(profile_id)
        get_db()
            .execute("
                UPDATE profiles
                SET active = 1
                WHERE profile_id = ?",
                profile_id)
    end

    # Deactivates a profile such that it cannot be viewed publicly
    #
    # @param [Integer] profile_id, The ID of the profile to deactivate
    def deactivate_profile(profile_id)
        get_db()
            .execute("
                UPDATE profiles
                SET active = 0
                WHERE profile_id = ?",
                profile_id)
    end

    # Deletes a post
    #
    # @param [Integer] post_id, The ID of the post to delete
    def delete_post(post_id)
        db = get_db()

        # Delete all likes related to the post
        db.execute("
            DELETE FROM likes
            WHERE likes.post_id = ?",
            post_id)

        # Delete the post itself
        db.execute("
            DELETE FROM posts
            WHERE posts.post_id = ?",
            post_id)
    end

    # Finds the ID of the user who wrote a given post
    #
    # @param [Integer] post_id, The ID of the post
    #
    # @return [Integer] The ID of the author user
    def get_post_author(post_id)
        return get_db()
            .execute("
                SELECT posts.user_id FROM posts
                WHERE posts.post_id = ?",
                post_id)
            .first["user_id"].to_i
    end

    # Checks whether a given user ID matches a valid admin user
    #
    # @param [Integer] user_id, The ID of the user
    #
    # @return [Boolean] Whether the user ID matches a valid admin user
    def is_valid_admin(user_id)
        return (user_id != nil) && !get_db()
            .execute("
                SELECT 1 FROM users
                WHERE user_id = ?
                AND username = 'Admin'",
                user_id).empty?
    end
end
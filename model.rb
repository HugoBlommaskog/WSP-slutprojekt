require('sqlite3')
require('bcrypt')
require('sinatra/flash')

module Model

    def get_db()
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        return db
    end

    def register(username, password)
    password_digest = BCrypt::Password.create(password)
    db = get_db()
    db.execute(
        "INSERT INTO users (username, password_hash) 
            VALUES (?, ?)", username, password_digest)
    created_user_id = db.last_insert_row_id()
    puts "ID of created user: #{created_user_id}"

    created_user = db.execute("SELECT * FROM users WHERE user_id = ?", created_user_id).first
    return created_user
    end

    def login(username, password)
        user = get_db().execute(
            "SELECT * FROM users 
                WHERE username = ?",
            username).first

        if user == nil
            # No user exists with that username
            puts ("ERROR: No user exists with username [#{username}]")
            flash[:notice] = "Failed to log in - Invalid username"
            return nil
        end

        password_digest = user["password_hash"]

        if (BCrypt::Password.new(password_digest) != password)
            # Incorrect password
            puts ("ERROR: Incorrect password [#{password}] for user [#{username}]")
            flash[:notice] = "Failed to log in - Incorrect password for username: [#{username}]"
            sleep(3)
            return nil
        end

        return user
    end

    def create_profile(profile_name)
        db = get_db()
        exists_by_name = db.execute(
            "SELECT 1 FROM profiles
                WHERE name = ?",
            profile_name).length() != 0

        if exists_by_name
            # Duplicate profile name
            return nil
        end

        db.execute(
            "INSERT INTO profiles (name) 
                VALUES (?)",
            profile_name)

        created_profile_id = db.last_insert_row_id()
        puts "ID of created profile: #{created_profile_id}"

        created_profile = db.execute(
            "SELECT * FROM profiles 
                WHERE profile_id = ?", 
            created_profile_id).first

        return created_profile
    end

    def get_profile(profile_id, maybe_user_id)
        puts "Getting profile"

        if (maybe_user_id != nil && is_valid_admin(maybe_user_id))
            profiles = get_db().execute(
                "SELECT * FROM profiles
                    WHERE profile_id = ?",
                profile_id)
        else
            profiles = get_db().execute(
                "SELECT * FROM profiles
                    WHERE profile_id = ? AND active = 1",
                profile_id)
        end

        if profiles == []
            puts "INVALID PROFILE SEARCH"
            return nil
        end

        puts ("Returning first")
        return profiles.first()
    end

    def get_all_profiles()
        puts "Getting ALL profiles"
        profiles = get_db().execute("
            SELECT * FROM profiles
            WHERE profiles.active = 1")

        return profiles
    end

    def search_profiles(prefix, maybe_user_id)
        puts "Searching for profiles matching #{prefix}?"

        # Yes, I know using #{prefix} in SQL is bad but it doesn't work with the ? injection

        if (maybe_user_id != nil && is_valid_admin(maybe_user_id))
            puts "Searching as admin, showing all options"

            profiles = get_db().execute(
                "SELECT * FROM profiles
                    WHERE profiles.name LIKE '#{prefix}%'")
        else
            puts "Searching as ordinary user"

            profiles = get_db().execute(
                "SELECT * FROM profiles
                    WHERE profiles.name LIKE '#{prefix}%' AND profiles.active = 1")
        end
        p profiles

        return profiles
    end

    def create_post(user_id, profile_id, message)
        db = get_db()
        db.execute(
            "INSERT INTO posts (user_id, profile_id, message)
                VALUES(?, ?, ?)",
            user_id,
            profile_id,
            message)

        created_post_id = db.last_insert_row_id()
        
        puts "Created post with ID #{created_post_id}"
    end

    def get_posts_about_profile(profile_id)
        db = get_db()
        posts = db.execute(
            "SELECT posts.post_id           AS post_id,
                    posts.user_id           AS author_id,
                    posts.profile_id        AS profile_id,
                    posts.message           AS message,
                    author.username         AS username,
                    profiles.name           AS profile_name,
                    COUNT(likes.like_id)    AS like_count
            FROM posts
            INNER JOIN profiles ON posts.profile_id = profiles.profile_id AND profiles.profile_id = ?
            INNER JOIN users AS author ON posts.user_id = author.user_id
            LEFT JOIN likes ON posts.post_id = likes.post_id
            GROUP BY posts.post_id",
            profile_id)
        
        return posts
    end

    def create_subscription(user_id, profile_id)
        db = get_db()
        db.execute(
            "INSERT INTO subscriptions (user_id, profile_id) VALUES (?, ?)",
            user_id,
            profile_id)

        created_subscription_id = db.last_insert_row_id()

        return created_subscription_id
    end

    def is_user_subscribed(user_id, profile_id)
        return (user_id != nil) && !get_db()
            .execute(
                "SELECT 1 FROM subscriptions
                    WHERE user_id = ? AND profile_id = ?",
                user_id, profile_id).empty?
    end

    def delete_subscription(user_id, profile_id)
        get_db()
            .execute(
                "DELETE FROM subscriptions
                    WHERE user_id = ? AND profile_id = ?",
                user_id,
                profile_id)
    end

    def get_user_subscribed_posts(user_id)
        db = get_db()
        posts = db
            .execute(
                "SELECT posts.post_id           AS post_id, 
                        posts.user_id           AS author_id, 
                        posts.profile_id        AS profile_id, 
                        posts.message           AS message, 
                        author.username         AS username, 
                        profiles.name           AS profile_name, 
                        COUNT(likes.like_id)    AS like_count
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

    def get_user_liked_post_ids(user_id)
        post_ids = get_db()
            .execute(
                "SELECT DISTINCT posts.post_id
                    FROM posts
                INNER JOIN likes ON posts.post_id = likes.post_id AND likes.user_id = ?",
                user_id
            )

        return post_ids
    end

    def create_like(user_id, post_id)
        get_db()
            .execute(
                "INSERT INTO likes (user_id, post_id) VALUES (?, ?)",
                user_id,
                post_id)
    end

    def delete_like(user_id, post_id)
        get_db()
            .execute(
                "DELETE FROM likes
                    WHERE user_id = ? AND post_id = ?",
                user_id,
                post_id)
    end

    def activate_profile(profile_id)
        get_db()
            .execute("
                UPDATE profiles
                SET active = 1
                WHERE profile_id = ?",
                profile_id)
    end

    def deactivate_profile(profile_id)
        get_db()
            .execute("
                UPDATE profiles
                SET active = 0
                WHERE profile_id = ?",
                profile_id)
    end

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

    # Check if a given user_id matches the author of a given post
    def get_post_author(post_id)
        return get_db()
            .execute("
                SELECT posts.user_id FROM posts
                WHERE posts.post_id = ?",
                post_id)
            .first["user_id"]
        
        return post["user_id"] == user_id
    end

    def is_valid_admin(user_id)
        return (user_id != nil) && !get_db()
            .execute(
                "SELECT 1 FROM users
                    WHERE user_id = ?
                        AND username = 'Admin'",
                user_id).empty?
    end
end
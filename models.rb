require('sqlite3')
require('bcrypt')

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
        puts ("No user exists with username [#{username}]")
        return nil
    end

    password_digest = user["password_hash"]

    if (BCrypt::Password.new(password_digest) != password)
        # Incorrect password
        puts ("Incorrect password [#{password}] for user [#{username}]")
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

    puts "Exists by name: #{exists_by_name}"

    if exists_by_name
        # Duplicate profile, send error message
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

def get_profile(profile_id)
    puts "Getting profile"
    profiles = get_db().execute(
        "SELECT * FROM profiles
            WHERE profile_id = ?",
        profile_id)

    if profiles == []
        puts "INVALID PROFILE SEARCH"
        return nil
    end

    puts ("Returning first")
    return profiles.first()
end

def get_all_profiles()
    puts "Getting ALL profiles"
    profiles = get_db().execute("SELECT * FROM profiles")

    return profiles
end

def search_profiles(prefix)
    puts "Searching for profiles matching #{prefix}?"
    # TODO: Fix up this potential for SQL injection
    profiles = get_db().execute(
        "SELECT * FROM profiles
            WHERE name LIKE '#{prefix}%'")

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
    puts "Retrieving posts about profile with ID #{profile_id}"
    db = get_db()
    posts = db.execute(
        "SELECT * FROM posts
            INNER JOIN users ON posts.user_id = users.user_id
            WHERE posts.profile_id = ?",
        profile_id)
    
    return posts
end
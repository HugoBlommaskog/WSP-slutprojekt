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
  db.execute("INSERT INTO users (username, password_hash) values (?, ?)", username, password_digest)
  created_user_id = db.last_insert_row_id()
  puts "ID of created user: #{created_user_id}"

  created_user = db.execute("SELECT * FROM users WHERE user_id = ?", created_user_id).first
  return created_user
end

def user(username, password)

end
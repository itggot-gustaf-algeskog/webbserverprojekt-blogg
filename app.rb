require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

get('/') do
    db = SQLite3::Database.new('db/blogg.db')
    db.results_as_hash = true

    posts = db.execute("SELECT Post,Image,Postid FROM posts")

    poster = db.execute("SELECT Poster FROM posts WHERE Userid = (?)",session[:id])

    if poster != []
        session[:poster] = poster[0][0]
    end

    p posts
    p session[:post_id]
    p session[:poster]

    slim(:index, locals:{ posts: posts})
end

get('/login') do
    slim(:login)
end

get('/register') do
    slim(:registrera)
end

get('/skapa_inlägg') do
    slim(:skapa_inlägg)
end

get('/profile') do
    db = SQLite3::Database.new('db/blogg.db')
    db.results_as_hash = true

    profiles = db.execute("SELECT Username,Name,Food,Color,Description FROM profiles WHERE Username = (?)",session[:username])

    slim(:profile, locals:{ profiles: profiles})
end

post('/logga_in') do
    db = SQLite3::Database.new('db/blogg.db')
    db.results_as_hash = true

    session[:username] = params["username"]
    session[:password] = params["password"]

    person = db.execute("SELECT (Id) FROM users WHERE Name = (?)",session[:username])
    
    if person[0] == nil
        redirect('/no_access')
    else
        session[:id] = person[0][0]
    end

    info = db.execute("SELECT * FROM users WHERE Id = (?)",session[:id])

    if session[:username] == info[0][0] and BCrypt::Password.new(info[0][1]) == session[:password]
        redirect('/')
    else
        redirect('/no_access')
    end
end

post('/registrering') do
    db = SQLite3::Database.new('db/blogg.db')
    db.results_as_hash = true

    session[:new_username] = params["new_username"]
    session[:new_password] = params["new_password"]
    session[:confirm_password] = params["confirm_password"]

    existing_username = db.execute("SELECT Name FROM users WHERE Name = (?)",session[:new_username])
    if existing_username == []
        existing_username = ""
    else
        existing_username = existing_username[0][0]
    end

    if session[:new_username] == ""
    elsif existing_username == session[:new_username]
    elsif session[:new_password] == ""
    elsif session[:new_password] != session[:confirm_password]
    else
        hashat_password = BCrypt::Password.create(session[:new_password])
        db.execute("INSERT INTO users (Name,Secret) VALUES (?,?)",session[:new_username],hashat_password)
        db.execute("INSERT INTO profiles (Name,Food,Color,Description,Username) VALUES (?,?,?,?,?)","hej","hej","hej","hej",session[:new_username])
    end
    
    redirect('/')
end

post('/create_post') do
    db = SQLite3::Database.new('db/blogg.db')
    db.results_as_hash = true

    session[:post] = params["post"]
    session[:blogg_bild] = params["blogg_bild"]

    if session[:post] == ""
    elsif session[:id] == nil
        redirect('/login')
    else
        db.execute("INSERT INTO posts (Post,Image,Userid,Poster) VALUES (?,?,?,?)",session[:post],session[:blogg_bild],session[:id],session[:username])
    end

    redirect('/')
end

post('/logout') do
    session[:username] = nil
    session[:password] = nil
    session[:id] = nil
    redirect('/')
end

get('/edit_post/:id') do
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true

    session[:post_id] = params["id"]

    slim(:edit_post)
end

get('/edit_profile') do
    slim(:edit_profile)
end

post('/update_profile') do
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true

    session[:namn] = params["namn"]
    session[:food] = params["food"]
    session[:color] = params["color"]
    session[:beskrivning] = params["beskrivning"]

    db.execute("UPDATE profiles SET Name = ?, Food = ?, Color = ?, Description = ? WHERE Username = ?",session[:namn],session[:food],session[:color],session[:beskrivning],session[:username])

    redirect('/profile')
end

post('/delete_post') do
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true

    db.execute("DELETE FROM posts WHERE Postid = ?", session[:post_id])

    redirect('/')
end

post('/redigera') do
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true

    session[:update_blogg_bild] = params["update_blogg_bild"]
    session[:update_post] = params["update_post"]

    db.execute("UPDATE posts SET Post = ?, Image = ? WHERE Postid = ?",session[:update_post],session[:update_blogg_bild],session[:post_id])

    redirect('/')
end
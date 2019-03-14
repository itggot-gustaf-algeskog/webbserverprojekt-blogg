require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

get('/') do
    db = SQLite3::Database.new('db/blogg.db')
    db.results_as_hash = true

    posts = db.execute("SELECT Post,Image FROM posts")

    p posts

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

post('/logga_in') do
    db = SQLite3::Database.new('db/blogg.db')
    db.results_as_hash = true

    session[:username] = params["username"]
    session[:password] = params["password"]

    person = db.execute("SELECT (Id) FROM users WHERE Name = (?)",session[:username])
    
    if person[0] == nil
        redirect('/no_access')
    else
        person_id = person[0][0]
        session[:id] = person[0][0]
    end

    info = db.execute("SELECT * FROM users")

    if session[:username] == info[person_id-1][0] and BCrypt::Password.new(info[person_id-1][1]) == session[:password]
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

    if session[:new_username] == ""
    elsif session[:new_password] == ""
    else
        hashat_password = BCrypt::Password.create(session[:new_password])
        db.execute("INSERT INTO users (Name,Secret) VALUES (?,?)",session[:new_username],hashat_password)
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
        db.execute("INSERT INTO posts (Post,Image,Id) VALUES (?,?,?)",session[:post],session[:blogg_bild],session[:id])
    end

    redirect('/')
end
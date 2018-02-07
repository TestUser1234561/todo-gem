require './config/environment'

class ApplicationController < Sinatra::Base

    #Configure environment
    configure do
        enable :sessions
        set :session_secret, '168'
        set :public_folder, 'public'
        set :views, 'app/views'
    end

    #Display index
    get '/' do
        #Send user to list if they are already logged in
        redirect to '/list' if session[:user_id]

        #Display index
        erb :index
    end

    #signup
    get '/signup' do
        #Send user to list if they are already logged in
        redirect to '/list' if session[:user_id]

        #Display sign up
        erb :signup
    end

    #Create new user
    post '/signup' do
        #Check user inputs
        redirect to '/signup' if params[:username] == "" && params[:email] == "" && params[:password] == ""

        #Create new user
        user = Users.new(username: params[:username], email: params[:email], password: [:password])

        #Try to save user and login
        if user.save
            session[:user_id] = user.id
            redirect to 'list'
        else
            #Something went wrong
            redirect to '/error'
        end
    end

    #Login
    get '/login' do
        #Send user to list if they are already logged in
        redirect to '/list' if session[:user_id]

        #Display login
        erb :login
    end

    #Log user in
    post '/login' do
        #Check for filled in data
        redirect to '/login' if params[:email] == "" && params[:password] == ""

        #Find user
        user = Users.find_by(email: params[:email])

        #Authenticate user
        if user && user.authenticate(params[:password])
            session[:user_id] = user.id
            redirect to 'list'
        else
            #Authentication failed
            redirect to '/login'
        end
    end

end
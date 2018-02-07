require './config/environment'

class ApplicationController < Sinatra::Base

    #Configure environment
    configure do
        enable :sessions
        set :session_secret, '168'
        set :public_folder, 'public'
        set :views, 'app/views'
    end

    before %r{/(signup|login)} do
        #Send user to list if they are already logged in
        redirect to '/list' if session[:user_id]
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
        erb :signup
    end

    #Create new user
    post '/signup' do
        #Check user inputs
        redirect to '/signup' if params[:username] == "" && params[:email] == "" && params[:password] == ""

        #Create new user
        user = Users.new(username: params[:username], email: params[:email], password: params[:password])

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
        erb :login
    end

    #Log user in
    post '/login' do
        #Check for filled in data
        redirect to '/login' if params[:email] == "" && params[:password] == ""

        #Authenticate user
        user = Users.find_by(email: params[:email]).try(:authenticate, params[:password])

        #Check user auth
        if user
            session[:user_id] = user.id
            redirect to '/list'
        else
            #Authentication failed
            redirect to '/login'
        end
    end

    #Run before any list routes
    before '/list/*' do
        #Send user to index if they are not logged in
        redirect to '/' unless session[:user_id]
    end

    #Lists
    get '/list' do
        #Display user's list
        @user = Users.find_by(id: session[:user_id])
        erb :'list/list'
    end

    get '/logout' do
        session[:user_id] = nil

        redirect to '/'
    end

end
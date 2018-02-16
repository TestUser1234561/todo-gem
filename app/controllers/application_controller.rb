require './config/environment'

class ApplicationController < Sinatra::Base

    #Configure environment
    configure do
        enable :sessions
        set :session_secret, '168'
        set :public_folder, 'public'
        set :views, 'app/views'
    end

    helpers do
        def current_user
            User.find(session[:user_id]) if session[:user_id]
        end
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

        #Check if email is in use
        redirect to '/signup' if User.find_by(email: params[:email])

        #Create new user
        user = User.new(username: params[:username], email: params[:email], password: params[:password])

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
        user = User.find_by(email: params[:email]).try(:authenticate, params[:password])

        #Check user auth
        if user
            session[:user_id] = user.id
            redirect to '/list'
        else
            #Authentication failed
            redirect to '/login'
        end
    end

    #Logout
    get '/logout' do
        session[:user_id] = nil
        redirect to '/'
    end

    #Run before any list routes
    before /\/list\/(.*)|\/list/ do
        #Send user to index if they are not logged in
        redirect to '/' unless session[:user_id]
    end

    #Lists
    get '/list' do
        #Display user's list
        @user = current_user
        erb :'list/list'
    end

    #Add task
    get'/list/add' do
        erb :'list/add'
    end

    post '/list/add' do
        task = Task.create(content: params[:content])
        current_user.tasks << task
        redirect to '/list'
    end

    #Edit task
    get '/list/:id/edit' do |id|
        #Find task
        @task = Task.find(id)
        #Render edit
        erb :'list/edit'
    end

    patch '/list/:id/check' do |id|
        #Find task
        task = Task.find_by(id: id)
        #Update task if it belongs to the current user
        task.update(done: !task.done) if task.user_id == current_user.id
        #Redirect to list
        redirect to '/list'
    end

    patch '/list/:id' do |id|
        #Find task
        task = Task.find(id)
        #Update task if it belongs to the current user
        task.update(content: params[:content]) if task.user_id == current_user.id
        #Redirect to task
        redirect to '/list'
    end

    #Delete task
    delete '/list/:id' do |id|
        #Find task
        task = Task.find(id)
        #Delete task if it belongs to the current user
        task.delete if task.user_id == current_user.id
        #Redirect to list
        redirect to '/list'
    end

    #Task detailed
    get '/list/:id' do |id|
        #Find task
        @task = Task.find(id)
        #Get user
        @user = current_user
        #Check if task belongs to user
        redirect to '/list' unless @task.user_id == current_user.id
        #Render task
        erb :'list/show'
    end

end
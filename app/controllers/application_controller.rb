require './config/environment'

class ApplicationController < Sinatra::Base

    configure do
        enable :sessions
        set :session_secret, '168'
        set :public_folder, 'public'
        set :views, 'app/views'
    end

    get '/' do
        "Hello World!"
    end

end
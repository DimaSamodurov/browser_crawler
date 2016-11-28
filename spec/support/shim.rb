require 'sinatra/base'

class Shim < Sinatra::Base
  get '/' do
    'Hello world!'
  end
end

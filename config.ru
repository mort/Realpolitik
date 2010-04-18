require 'rubygems' 
require 'sinatra'

set :run, false 
set :environment, :development

require 'app' 
run Sinatra::Application
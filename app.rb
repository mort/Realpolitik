require 'rubygems'
require 'sinatra'
require 'rp'

get '/' do
  @assertions = Assertion.all :order => 'updated_at DESC'
  erb :assertions
end

get '/stories' do
  @stories = Story.all :order => 'title ASC'
  erb :stories
end

get '/stories/:id' do
  @story = Story.find(params[:id])
  erb :story
end

get '/entities' do
  @entities = Entity.all :include => [:as_predicate, :as_subject, :stories], :order => 'text ASC'
  erb :entities
end

get '/entities/:id' do
  @verbs = Assertion::VERBS
  @entity = Entity.find(params[:id])
  @entities = Entity.all :conditions => ['id <> ?', @entity.id], :order => 'text ASC'
  
  erb :entity
end

post '/entities/:entity_id/assertions' do
  e = Entity.find params[:entity_id]
  e.as_subject.create(params[:assertion])
  
  redirect '/entities/' + e.id.to_s
end

get '/assertions' do
  @assertions = Assertion.all :include => [:predicate, :subject], :order => 'updated_at DESC'
  
  erb :assertions
end

post '/assertions/:id/toggle' do
  a = Assertion.find(params[:id])
  a.update_attribute(:status, (1 - a.status))

  redirect '/assertions'
end

post '/entities/mass_delete' do
  params[:ids].each do |id|
    Entity.find(id).destroy
  end
  redirect '/entities'
end

get '/autocomplete' do 
  q = params[:q]
  @entities = Entity.find(:all, :conditions => "text LIKE '%#{q}%'", :order => 'text ASC')
  erb :autocomplete, :layout => false
end

get '/about' do
  erb :about
end

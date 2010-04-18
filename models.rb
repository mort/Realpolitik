require 'rubygems'
require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

ActiveRecord::Base.establish_connection(
    :adapter => "mysql",
    :username  => "root",
    :database => 'realpolitik'
)

 ActiveRecord::Schema.define do
#     create_table :entities, :options => "ENGINE=MyISAM" do |table|
#         table.column :text, :string
#         table.column :kind, :string
#         table.column :relevance, :float
#         table.column :count, :integer
#     end
# 
#     create_table :taggings do |table|
#         table.column :story_id, :integer
#         table.column :entity_id, :integer
#     end
#     
#     create_table :stories do |table|
#       table.column :title, :string
#       table.column :url, :string
#       table.column :summary, :string
#       table.column :content, :text
#       table.column :published_at, :datetime
#       table.column :created_at, :datetime
#     end
#     
    # create_table :assertions do |table|
    #   table.column :subject_id, :integer
    #   table.column :predicate_id, :integer
    #   table.column :verb, :string
    #   table.column :status, :integer, :null => false, :default => 1 
    #   table.column :true_count, :integer, :null => false, :default => 0
    #   table.column :false_count, :integer, :null => false, :default => 0
    #   table.column :created_at, :datetime
    #   table.column :updated_at, :datetime      
    # end

    #execute "CREATE FULLTEXT INDEX FullText_Entities ON entities (text)"
  end



class Entity < ActiveRecord::Base
    validates_uniqueness_of :text, :scope => :kind
  
    has_many :taggings
    has_many :stories, :through => :taggings
    
    has_many :as_subject, :foreign_key => 'subject_id', :class_name => 'Assertion'
    has_many :as_predicate, :foreign_key => 'predicate_id', :class_name => 'Assertion'
    
end

class Tagging < ActiveRecord::Base
    belongs_to :entity
    belongs_to :story
end

class Story < ActiveRecord::Base
  validates_uniqueness_of :url
  
  require 'uri'
  
  
  has_many :taggings
  has_many :entities, :through => :taggings

  def source
    uri = URI.parse(url)
    uri.host
  end
end

class Assertion < ActiveRecord::Base
  validates_presence_of :subject_id, :predicate_id, :verb
  validates_uniqueness_of :subject_id, :scope => [:predicate_id, :verb]
  belongs_to :subject, :class_name => 'Entity'
  belongs_to :predicate, :class_name => 'Entity'
  
  named_scope :true, :conditions => 'status = 1'
  named_scope :false, :conditions => 'status = 0'
  
  # igualA se utiliza con el término preferido de sujeto, sinonimoDe de predicado
  # perteneceA para personas > organizaciones
  VERBS = {'igualA' => 'tiene como sinónimo a',
           'sinonimoDe' => 'es más conocido como',
           'perteneceA' => 'pertenece a', 
           'tieneMiembro' => 'tiene como miembro a', 
           'parteDe' => 'es parte de', 
           'conocidoAntes' => 'era conocido antes como', 
           'compañeroDe' => 'es compañero de',
           'resideEn' => 'reside en'
           }  
  def text
    VERBS[self.verb]
  end
end
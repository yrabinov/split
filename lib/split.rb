require 'split/experiment'
require 'split/alternative'
require 'split/helper'
require 'split/version'
require 'split/configuration'
require 'split/database'

module Split
  extend self
  attr_accessor :configuration

  # Call this method to modify defaults in your initializers.
  #
  # @example
  #   Split.configure do |config|
  #     config.ignore_ips = '192.168.2.1'
  #   end
  def configure
     self.configuration ||= Configuration.new
     yield(configuration)
   end
   
   def db
     @db ||= Split::Database.new
   end
end

Split.configure {}

if defined?(Rails)
  class ActionController::Base
    ActionController::Base.send :include, Split::Helper
    ActionController::Base.helper Split::Helper
  end
end

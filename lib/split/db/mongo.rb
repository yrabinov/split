require 'mongo'

module Split
  module DB
    module Mongo
      def server=(url)
        @conn = ::Mongo::Connection.new
        @db   = @conn['sample-db']
        @server = @db['test']
      end

      def server
        return @server if @server
        self.server = 'localhost'
        self.server
      end

      def clean
        self.server.drop
      end

      def exists?(experiment_name)
        self.server.count(:name => experiment_name) > 0
      end

      def find(experiment_name)
        self.server.find(:name => experiment_name).first
      end

      def save(experiment_name, alternatives, time)
        self.server.insert({:name => experiment_name, 
                            :created_at => time,
                            :alternatives => alternatives.map{|a| {:name => a.name}}})
      end

      def alternatives(experiment_name)
        self.find(experiment_name)[:alternatives]
      end

      def start_time(experiment_name)
        self.find(experiment_name)[:created_at]
      end

      def delete(experiment_name)
        self.server.remove(:name => experiment_name)
      end

      def version(experiment_name)
        self.find(experiment_name)[:version]
      end
      
      def winner(experiment_name)
        self.find(experiment_name)[:winner]
      end
      
      def all_experiments
        self.server.find.to_a
      end
    end
  end
end
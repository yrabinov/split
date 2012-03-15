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

      # def exists?(experiment_key)
      # 
      # end
      # 
      # def get(experiment_key, attribute = nil)
      # 
      # end
      # 
      # def set(experiment_key, attribute_or_value, value=nil)
      # 
      # end
      # 
      # def incr(experiment_key, attribute=nil)
      # 
      # end
      # 
      # def delete(experiment_key)
      # 
      # end
      # 
      # def type(key)
      # 
      # end
      # 
      # def reset(experiment_key)
      # 
      # end
      # 
      # def hsetnx(key, attribute, value)
      # 
      # end
      # 
      # def hdel(key, attribute)
      # 
      # end
      # 
      # def srem(key, attribute)
      # 
      # end
      # 
      # def sadd(key, attribute)
      # 
      # end
      # 
      # def lpush(key, value)
      # 
      # end
      # 
      # def smembers(key)
      # 
      # end
      # 
      # def lrange(key, first, last)
      # 
      # end
    end
  end
end
module Split
  module DB
    module Redis
      # Accepts:
      #   1. A 'hostname:port' string
      #   2. A 'hostname:port:db' string (to select the Redis db)
      #   3. A 'hostname:port/namespace' string (to set the Redis namespace)
      #   4. A redis URL string 'redis://host:port'
      #   5. An instance of `Redis`, `Redis::Client`, `Redis::DistRedis`,
      #      or `Redis::Namespace`.
      def server=(server)
        if server.respond_to? :split
          if server =~ /redis\:\/\//
            redis = ::Redis.connect(:url => server, :thread_safe => true)
          else
            server, namespace = server.split('/', 2)
            host, port, db = server.split(':')
            redis = ::Redis.new(:host => host, :port => port,
              :thread_safe => true, :db => db)
          end
          namespace ||= :split

          @server = ::Redis::Namespace.new(namespace, :redis => redis)
        elsif server.respond_to? :namespace=
            @server = server
        else
          @server = ::Redis::Namespace.new(:split, :redis => server)
        end
      end

      # Returns the current Redis connection. If none has been created, will
      # create a new one.
      def server
        return @server if @server
        self.server = 'localhost:6379'
        self.server
      end
      
      def clean
        server.flushall
      end
      
      def exists?(experiment_key)
        self.server.exists(experiment_key)
      end

      def get(experiment_key, attribute = nil)
        if attribute
          self.server.hget(experiment_key, attribute)
        else
          self.server.get(experiment_key)
        end
      end

      def set(experiment_key, attribute_or_value, value=nil)
        if value
          self.server.hset(experiment_key, attribute_or_value, value)
        else
          self.server.set(experiment_key, attribute_or_value)
        end
      end

      def incr(experiment_key, attribute=nil)
        if attribute
          self.server.hincrby experiment_key, attribute, 1
        else
          self.server.incr(experiment_key)
        end
      end

      def delete(experiment_key)
        self.server.del(experiment_key)
      end

      def type(key)
        self.server.type(key)
      end
    
      def reset(experiment_key)
        self.server.hmset experiment_key, 'participant_count', 0, 'completed_count', 0
      end

      def hsetnx(key, attribute, value)
        self.server.hsetnx  key, attribute, value
      end
      
      def hdel(key, attribute)
        self.server.hdel(key, attribute)
      end
      
      def srem(key, attribute)
        self.server.srem(key, attribute)
      end
      
      def sadd(key, attribute)
        self.server.sadd(key, attribute)
      end
      
      def lpush(key, value)
        self.server.lpush(key, value)
      end
      
      def smembers(key)
        self.server.smembers(key)
      end
      
      def lrange(key, first, last)
        self.server.lrange(key, first, last)
      end
    end
  end
end
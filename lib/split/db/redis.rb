module Split
  module DB
    module Redis
      def exists?(key)
        Split.redis.exists(key)
      end

      def get(key, attribute = nil)
        if attribute
          Split.redis.hget(key, attribute)
        else
          Split.redis.get(key)
        end
      end

      def set(key, attribute_or_value, value=nil)
        if value
          Split.redis.hset(key, attribute_or_value, value)
        else
          Split.redis.set(key, attribute_or_value)
        end
      end

      def incr(key, attribute=nil)
        if attribute
          Split.redis.hincrby key, attribute, 1
        else
          Split.redis.incr(key)
        end
      end

      def delete(key)
        Split.redis.del(key)
      end

      def type(key)
        Split.redis.type(key)
      end
    
      def reset(key)
        Split.redis.hmset key, 'participant_count', 0, 'completed_count', 0
      end

      # hsetnx
      # srem
      # sadd
      # lpush
      # smembers
      # lrange
    end
  end
end
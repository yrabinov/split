module Split
  module DB
    module Redis
      def exists?(experiment_key)
        Split.redis.exists(experiment_key)
      end

      def get(experiment_key, attribute = nil)
        if attribute
          Split.redis.hget(experiment_key, attribute)
        else
          Split.redis.get(experiment_key)
        end
      end

      def set(experiment_key, attribute_or_value, value=nil)
        if value
          Split.redis.hset(experiment_key, attribute_or_value, value)
        else
          Split.redis.set(experiment_key, attribute_or_value)
        end
      end

      def incr(experiment_key, attribute=nil)
        if attribute
          Split.redis.hincrby experiment_key, attribute, 1
        else
          Split.redis.incr(experiment_key)
        end
      end

      def delete(experiment_key)
        Split.redis.del(experiment_key)
      end

      def type(key)
        Split.redis.type(key)
      end
    
      def reset(experiment_key)
        Split.redis.hmset experiment_key, 'participant_count', 0, 'completed_count', 0
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
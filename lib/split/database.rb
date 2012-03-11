require 'split/redis'
module Split
  class Database
    include Split::RedisAdapter
  end
end
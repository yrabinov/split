require 'split/db/redis'
module Split
  class Database
    include Split::DB::Redis
  end
end
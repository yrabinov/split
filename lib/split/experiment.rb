module Split
  class Experiment
    attr_accessor :name
    attr_accessor :winner

    def initialize(name, *alternative_names)
      @name = name.to_s
      @alternatives = alternative_names.map do |alternative|
                        Split::Alternative.new(alternative, name)
                      end
    end

    def winner
      if w = Split.db.get(:experiment_winner, name)
        Split::Alternative.new(w, name)
      else
        nil
      end
    end

    def control
      alternatives.first
    end

    def reset_winner
      Split.db.hdel(:experiment_winner, name)
    end

    def winner=(winner_name)
      Split.db.set(:experiment_winner, name, winner_name.to_s)
    end

    def start_time
      t = Split.db.get(:experiment_start_times, @name)
      Time.parse(t) if t
    end

    def alternatives
      @alternatives.dup
    end

    def alternative_names
      @alternatives.map(&:name)
    end

    def next_alternative
      winner || random_alternative
    end

    def random_alternative
      weights = alternatives.map(&:weight)

      total = weights.inject(:+)
      point = rand * total

      alternatives.zip(weights).each do |n,w|
        return n if w >= point
        point -= w
      end
    end

    def version
      @version ||= (Split.db.get("#{name.to_s}:version").to_i || 0)
    end

    def increment_version
      @version = Split.db.incr("#{name}:version")
    end

    def key
      if version.to_i > 0
        "#{name}:#{version}"
      else
        name
      end
    end

    def reset
      alternatives.each(&:reset)
      reset_winner
      increment_version
    end

    def delete
      alternatives.each(&:delete)
      reset_winner
      Split.db.srem(:experiments, name)
      Split.db.delete(name)
      increment_version
    end

    def new_record?
      !Split.db.exists?(name)
    end

    def save
      if new_record?
        Split.db.sadd(:experiments, name)
        Split.db.set(:experiment_start_times, @name, Time.now)
        @alternatives.reverse.each {|a| Split.db.lpush(name, a.name) }
      end
    end

    def self.load_alternatives_for(name)
      case Split.db.type(name)
      when 'set' # convert legacy sets to lists
        alts = Split.db.smembers(name)
        Split.db.delete(name)
        alts.reverse.each {|a| Split.db.lpush(name, a) }
        Split.db.lrange(name, 0, -1)
      else
        Split.db.lrange(name, 0, -1)
      end
    end

    def self.all
      Array(Split.db.smembers(:experiments)).map {|e| find(e)}
    end

    def self.find(name)
      if Split.db.exists?(name)
        self.new(name, *load_alternatives_for(name))
      end
    end

    def self.find_or_create(key, *alternatives)
      name = key.to_s.split(':')[0]

      if alternatives.length == 1
        if alternatives[0].is_a? Hash
          alternatives = alternatives[0].map{|k,v| {k => v} }
        else
          raise InvalidArgument, 'You must declare at least 2 alternatives'
        end
      end

      alts = initialize_alternatives(alternatives, name)

      if Split.db.exists?(name)
        if load_alternatives_for(name) == alts.map(&:name)
          experiment = self.new(name, *load_alternatives_for(name))
        else
          exp = self.new(name, *load_alternatives_for(name))
          exp.reset
          exp.alternatives.each(&:delete)
          experiment = self.new(name, *alternatives)
          experiment.save
        end
      else
        experiment = self.new(name, *alternatives)
        experiment.save
      end
      return experiment

    end

    def self.initialize_alternatives(alternatives, name)

      unless alternatives.all? { |a| Split::Alternative.valid?(a) }
        raise InvalidArgument, 'Alternatives must be strings'
      end

      alternatives.map do |alternative|
        Split::Alternative.new(alternative, name)
      end
    end
  end
end
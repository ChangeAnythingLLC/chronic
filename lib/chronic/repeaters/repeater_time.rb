module Chronic
  class RepeaterTime < Repeater #:nodoc:
    class Tick #:nodoc:
      attr_accessor :time

      def initialize(time, ambiguous = false)
        @time = time
        @ambiguous = ambiguous
      end

      def ambiguous?
        @ambiguous
      end

      def *(other)
        Tick.new(@time * other, @ambiguous)
      end

      def to_f
        @time.to_f
      end

      def to_s
        @time.to_s + (@ambiguous ? '?' : '')
      end
    end

    HALF_DAY = 60 * 60 * 12
    FULL_DAY = 60 * 60 * 24

    def initialize(time, width = nil, options = {})
      @current_time = nil
      @options = options
      time_parts = time.split(':')
      raise ArgumentError, "Time cannot have more than 4 groups of ':'" if time_parts.count > 4

      if time_parts.first.length > 2 and time_parts.count == 1
        if time_parts.first.length > 4
          second_index = time_parts.first.length - 2
          time_parts.insert(1, time_parts.first[second_index..time_parts.first.length])
          time_parts[0] = time_parts.first[0..second_index - 1]
        end
        minute_index = time_parts.first.length - 2
        time_parts.insert(1, time_parts.first[minute_index..time_parts.first.length])
        time_parts[0] = time_parts.first[0..minute_index - 1]
      end

      ambiguous = false
      hours = time_parts.first.to_i

      if @options[:hours24].nil? or (not @options[:hours24].nil? and @options[:hours24] != true)
          ambiguous = true if (time_parts.first.length == 1 and hours > 0) or (hours >= 10 and hours <= 12) or (@options[:hours24] == false and hours > 0)
          hours = 0 if hours == 12 and ambiguous
      end

      hours *= 60 * 60
      minutes = 0
      seconds = 0
      subseconds = 0

      minutes = time_parts[1].to_i * 60 if time_parts.count > 1
      seconds = time_parts[2].to_i if time_parts.count > 2
      subseconds = time_parts[3].to_f / (10 ** time_parts[3].length) if time_parts.count > 3

      @type = Tick.new(hours + minutes + seconds + subseconds, ambiguous)
    end

    # Return the next past or future Span for the time that this Repeater represents
    #   pointer - Symbol representing which temporal direction to fetch the next day
    #             must be either :past or :future
    def next(pointer)
      super
      first = false

      unless @current_time
        first = true
        midnight = Chronic.time_class.local(@now.year, @now.month, @now.day)

        catch :done do
          if @type.ambiguous?
            if pointer == :future
              [
                concat_time(midnight, @type.time),
                concat_time(midnight, HALF_DAY, @type.time),
                concat_time(midnight, FULL_DAY, @type.time)
              ].each do |t|
                (@current_time = t; throw :done) if t >= @now
              end
            else
              [
                concat_time(midnight, HALF_DAY, @type.time),
                concat_time(midnight, @type.time),
                concat_time(midnight, -HALF_DAY, @type.time),
              ].each do |t|
                (@current_time = t; throw :done) if t <= @now
              end
            end
          else
            if pointer == :future
              [
                concat_time(midnight, @type.time),
                concat_time(midnight, FULL_DAY, @type.time)
              ].each do |t|
                (@current_time = t; throw :done) if t >= @now
              end
            else
              [
                concat_time(midnight, @type.time),
                concat_time(midnight, -FULL_DAY, @type.time)
              ].each do |t|
                (@current_time = t; throw :done) if t <= @now
              end
            end
          end
        end

        @current_time || raise('Current time cannot be nil at this point')
      end

      unless first
        increment = @type.ambiguous? ? HALF_DAY : FULL_DAY
        @current_time += pointer == :future ? increment : -increment
      end

      Span.new(@current_time, @current_time + width)
    end

    def this(context = :future)
      super

      context = :future if context == :none

      self.next(context)
    end

    def width
      1
    end

    def to_s
      super << '-time-' << @type.to_s
    end

    private

    def concat_time(*items)
      initial_time_offset = items.first.gmt_offset
      new_time = items.inject(&:+)
      dst_time_shift = initial_time_offset - new_time.gmt_offset
      new_time + dst_time_shift
    end
  end
end

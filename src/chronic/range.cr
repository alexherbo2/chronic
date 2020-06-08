class Chronic::Range

  include Iterator(::Time)

  property step : ::Time::Span

  def self.new(range : ::Range(::Time, ::Time))
    new(range.begin, range.end, range.exclusive?)
  end

  def initialize(@begin : ::Time, @end : ::Time, @exclusive = false)
    @time = @begin
    @step = 1.second
  end

  def next
    if (@exclusive == true && @time < @end) || (@exclusive == false && @time <= @end)
      current_time = @time
      @time += @step
      current_time
    else
      stop
    end
  end

  def exclusive?
    @exclusive
  end

end

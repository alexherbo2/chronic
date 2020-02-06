class Chronic::Range

  include Iterator(::Time)

  property step : ::Time::Span

  def self.new(range : ::Range(::Time, ::Time))
    new(range.begin, range.end)
  end

  def initialize(@begin : ::Time, @end : ::Time)
    @time = @begin
    @step = 1.second
  end

  def next
    if @time < @end
      current_time = @time
      @time += @step
      current_time
    else
      stop
    end
  end

end

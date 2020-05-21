require "./duration"

struct Chronic::Time
  property time
  def initialize(@time : ::Time)
  end
  def from(time)
    @time - time
  end
  def from_now
    from(::Time.local)
  end
  def to_s(format)
    # Let’s just pretend we have a real parser.
    format = format.gsub("%+") do
      duration = Duration.new(from_now)
      duration.humanize
    end
    @time.to_s(format)
  end
end

struct Chronic::Duration
  property time
  def initialize(@time : ::Time::Span)
  end
  def humanize
    data = {
      "days" => @time.days,
      "hours" => @time.hours,
      "minutes" => @time.minutes,
      "seconds" => @time.seconds
    }
    data.each.reject(&.last.zero?).join(' ') do |unit, value|
      "#{value} #{unit}"
    end
  end
end

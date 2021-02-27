require "./chronic/parser"
require "./chronic/duration"
require "option_parser"

if STDIN.tty? && ARGV.empty?
  STDERR.puts <<-'EOF'
    Usage
    ‾‾‾‾‾
    [time = now] | chronic [format = %F %T]
      [--input | -i INPUT]
      [--days | -d DAYS] [--hours | -h HOURS] [--minutes | -m MINUTES] [--seconds | -s SECONDS]
      [--format | -f FORMAT] [--separator | -j SEPARATOR]
      [--sleep | -z]
      [--command | -x COMMAND]
      [--help]

    Syntax
    ‾‾‾‾‾‾
    | <time> [+|plus] [relative-time] | chronic [format]
    | <start-time> [..|-|→|to] <end-time> | chronic [format]
    | <time> [::] <relative-time> | chronic [format]

    Examples
    ‾‾‾‾‾‾‾‾
    Simple:
    $ echo today | chronic
    # 2020-02-02 19:00:00

    Increment a day:
    $ echo 2020-02-02 + tomorrow | chronic '%F'
    # 2020-02-03

    Same with --input option:
    $ echo 2020-02-02 | chronic '%F' --input '%s + tomorrow'
    # 2020-02-03

    Create a new diary:
    $ echo 01 January to 31 December | chronic '# %F' > ~/documents/diary/2020.md
    | # 2020-01-01
    | […]
    | # 2020-12-31

    Grep things to do over the next 7 days:
    $ grep $(chronic --input 'today → 7 days' 'TODO.+%F' --separator '|')
    Regex: TODO.+2020-02-02|TODO.+2020-02-03|TODO.+2020-02-04|TODO.+2020-02-05|TODO.+2020-02-06|TODO.+2020-02-07|TODO.+2020-02-08

    Set up an alarm:
    $ echo Tomorrow 09:00 AM | chronic --sleep
    $ mpv -shuffle ~/music
  EOF
  exit(1)
end

DEFAULT_INPUT = "now"
DEFAULT_FORMAT = "%F %T"

struct Options
  property input
  property days
  property hours
  property minutes
  property seconds
  property format
  property separator
  property sleep
  property command
  def initialize(@input = "%s", @days = 0, @hours = 0, @minutes = 0, @seconds = 0, @format = "%s", @separator = "\n", @sleep = false, @command : String? = nil)
  end
end

def main

  options = Options.new

  OptionParser.parse(ARGV) do |parser|
    parser.banner = "Usage: [time = now] | chronic [format = %F %T]"
    parser.on("-i INPUT", "--input=INPUT", "Set text input (Default: %s).  You can map stdin content with %s") { |input| options.input = input }
    parser.on("-d DAYS", "--days=DAYS", "Configure step in days (Default: 1)") { |days| options.days = days.to_i }
    parser.on("-h HOURS", "--hours=HOURS", "Configure step in hours") { |hours| options.hours = hours.to_i }
    parser.on("-m MINUTES", "--minutes=MINUTES", "Configure step in minutes") { |minutes| options.minutes = minutes.to_i }
    parser.on("-s SECONDS", "--seconds=SECONDS", "Configure step in seconds") { |seconds| options.seconds = seconds.to_i }
    parser.on("-f FORMAT", "--format=FORMAT", "Set text format (Default: %s)") { |format| options.format = format }
    parser.on("-j SEPARATOR", "--separator=SEPARATOR", "Configure separator (Default: ␤)") { |separator| options.separator = separator }
    parser.on("-z", "--sleep", "Sleep for the specified time span") { options.sleep = true }
    parser.on("-x COMMAND", "--command=COMMAND", "Execute command when the specified time passed.  Requires --sleep") { |command| options.command = command }
    parser.on("--help", "Display a help message and quit") { puts parser; exit }
    parser.invalid_option do |flag|
      STDERR.puts "Error: Unknown option: #{flag}"
      STDERR.puts parser
      exit(1)
    end
  end

  if { options.days, options.hours, options.minutes, options.seconds }.all? &.zero?
    options.days = 1
  end

  parser = Chronic::Parser.new

  # Arguments
  stdin_content = if STDIN.tty?
    DEFAULT_INPUT
  else
    STDIN.gets_to_end
  end
  # Get final text input from option
  input = options.input % stdin_content
  format = if ARGV.empty?
    DEFAULT_FORMAT
  else
    ARGV.join(' ')
  end

  # Handler
  handler = ->(time : Time) {
    time = Chronic::Time.new(time)
    text = options.format % time.to_s(format)
    # Sleep option
    if options.sleep
      time_span = time.from_now
      if time_span.to_i < 0
        STDERR.puts "The specified time has already passed: %F %T – %+"
      else
        STDERR.puts time.to_s("Sleeping until %F %T – %+")
        sleep(time_span)
        command = options.command
        if command
          system(command)
        end
      end
    end
    text
  }

  # Parse text input and format
  object = parser.parse(input)
  output = case object
  when Time
    handler.call(object)
  when Chronic::Range
    time_range = object
    period = Time::Span.new(days: options.days, hours: options.hours, minutes: options.minutes, seconds: options.seconds)
    time_range.step = period
    time_range.join(options.separator, &handler)
  else
    raise "Something went wrong"
  end

  # Print text output
  puts output

end

main

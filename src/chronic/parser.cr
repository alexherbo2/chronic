require "./time"
require "./range"

class Chronic::Parser

  def parse(text : String)
    tokens = tokenize(text)
    parse(tokens)
  end

  def tokenize(text)
    pre_normalize(text).split("::").map(&.strip.split("..").map(&.strip.split('+').map(&.strip)))
  end

  def pre_normalize(text)
    text
      .strip
      .gsub('\n', ' ')
      .squeeze(' ')
      .downcase
      .gsub(/\b(to)\b|\h(-)\h|(->|=>)|[–—→⇒]/, "..")
      .gsub(/\b(plus)\b/, '+')
  end

  def parse(tokens : Array(Array(Array(String))))
    case tokens.size
    when 1
      parse(tokens[0])
    when 2
      current_time = tokens[0][0]
      tokens = tokens[1].map do |tokens|
        current_time + tokens
      end
      parse(tokens)
    end
  end

  def parse(tokens : Array(Array(String)))
    case tokens.size
    when 1
      parse(tokens[0])
    when 2
      parse({ tokens[0], tokens[1] })
    end
  end

  # Note: Fix time computation by adding 1 second.
  # $ echo 2020-02-02 + tomorrow | chronic
  # # 2020-02-02 23:59:59
  def parse(tokens : Array(String))
    now = ::Time.local
    times = tokens.map &->Parser.parse(String)
    times.reduce do |compiled_time, time|
      compiled_time + Time.new(time).from(now) + 1.second
    end
  end

  def parse(tokens : Tuple(Array(String), Array(String)))
    start_time = parse(tokens[0])
    end_time = parse(tokens[1])
    Range.new(start_time, end_time)
  end

  def self.parse(text)
    stdout = IO::Memory.new
    stderr = IO::Memory.new
    status = Process.run(
      command: "date",
      args: { "--date", text, "+%s" },
      output: stdout,
      error: stderr
    )
    case status.exit_code
    when 0
      ::Time.unix(stdout.to_s.to_i).to_local
    else
      raise stderr.to_s
    end
  end

end

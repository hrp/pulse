require 'dotenv'
Dotenv.load

require 'colored'
require 'twitter'

class Pulse
  def initialize(tracks)
    @stream = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = ENV["CONSUMER_KEY"]
      config.consumer_secret     = ENV["CONSUMER_SECRET"]
      config.access_token        = ENV["ACCESS_TOKEN"]
      config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
    end

    @tracks = tracks
    @paints = {}
    prepare
    legend
  end

  def random_color
    Colored::COLORS.to_a.sample.first.to_sym
  end

  def prepare
    @tracks.each do |term|
      r1 = r2 = random_color
      while(r1 == r2) do
        r2 = random_color
      end
      @paints[term] = "#{r1}_on_#{r2}"
    end
  end

  def paint(str, color)
    print str.send(color)
  end

  def legend
    @tracks.each do |track|
      paint(track, @paints[track])
    end
    puts
  end

  def tracks_str
    @tracks.join(',')
  end

  def matching(text)
    @tracks.find do |track|
      text[/#{track}/i] && track
    end
  end

  def action!
    @stream.filter(track: tracks_str) do |tw|
      if tw.is_a?(Twitter::Tweet)
        # Find corresponding color or choose black if not found (truncated tweet)
        color = @paints[matching(tw.text)] || :black
        paint('.', color)
      end
    end
  end
end

# End nicely
trap("INT") { puts "Thanks for playing!"; exit }

# Allow CLI params
words = if ARGV.empty?
  %w(lol rofl lmao brb gtg omg yolo)
else
  ARGV
end
Pulse.new(words).action!

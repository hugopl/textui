require "option_parser"
require "yaml"

require "./app"

def detect_rails_database
  config = YAML.parse(File.read("./config/database.yml"))
  env = "development"
  hostname = config.dig?(env, "hostname") || "localhost"
  database = config.dig(env, "database")
  adapter = config.dig(env, "adapter")

  "#{adapter}://#{hostname}/#{database}"
rescue e : Errno
  raise "Could not find rails database configuration."
end

def parse_options
  uri = ""
  OptionParser.parse! do |parser|
    parser.banner = "Usage: queryit [arguments]"
    parser.on("--uri=URI", "Database server URI, e.g. postgres://localhost/database") { |db_uri| uri = db_uri }
    parser.on("-h", "--help", "Show this help.") { puts parser }
  end
  {uri: uri}
end

def main
  options = parse_options

  uri = URI.parse(options[:uri].empty? ? detect_rails_database : options[:uri])

  app = App.new(uri)
  app.main_loop
rescue e : Exception
  puts e.message
end

main

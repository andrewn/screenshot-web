# Simple screenshot webservice
# To run:
#   ruby webservice.rb
#
# To use: 
#  HTTP GET web.service.url/:url_to_grab
#
#


require 'rubygems'
require 'sinatra'
require 'time'

# Determine how many seconds to cache for
CACHE_EXPIRY_IN_SECS = 15 * 60

# Supported cache types
CACHE_NONE      = :none
CACHE_INTERNAL  = :internal
CACHE_RACK      = :rack

# Choose a cache type here
CACHE_TYPE = CACHE_RACK

if CACHE_TYPE == :internal then
  require 'memcached'
  CACHE = MemCache.new 'localhost:11211' #, :namespace => 'shot'
end

if CACHE_TYPE == :rack
  require 'rack/cache'
  use Rack::Cache,
    :verbose => true
end

#if options.environment == :production
  # port  
#end

HTTP  = "http://"
HTTPS = "https://"
PNG   = "png"
DOT   = "."

# How to create a digest.
# Digest::SHA1.hexdigest "frankmash.blogspot.com"
#  => "443072b4f12ca8796d901d5dce40924ef3c414fd"

# Routes
get '/' do 
 "<h1>Screenshot</h1>" + 
 options.environment.to_s
end

PATTERN_URL_DATE  = '/site/:url/:year/:month/:date/:hour/:min'
PATTERN_URL       = '/site/:url'

PATTERN           = PATTERN_URL

get PATTERN do
  # Test if params[:url] looks like URL
  looks_like_url = true
  pass unless looks_like_url
  
  url = params[:url]
  
  file_path = "/tmp/"
  file_name = url # sanitize!
  file      = file_path + file_name
  
  if CACHE_TYPE == :internal then
    # Fetch the filepath of the screenshot from 
    # the cache. If the cache is invalid then we 
    # create a new screenshot and put that in the 
    # cache.
    shot_path = get_from_cache_or_put_from_block( url, CACHE_EXPIRY_IN_SECS ) do 
      new_shot = create_screenshot( HTTP + params[:url], file )
      new_shot
    end
  else 
    shot_path = create_screenshot( HTTP + params[:url], file )
  end
  
#  headers( "Cache-Control" => "max-age=" + CACHE_EXPIRY_IN_SECS.to_s )
#  expires CACHE_EXPIRY_IN_SECS 
  response["Expires"] = (Time.now + CACHE_EXPIRY_IN_SECS).httpdate

  # Send the file back to the client
  send_file( shot_path )      if shot_path
  "Problem taking screenshot" unless shot_path
end

get PATTERN do
  # Retrieve from md5 in URL?
end

put PATTERN do 
  # Create a new shot???
end

def create_screenshot( url, path, extension = PNG ) 
  full_path = path + DOT + extension
  command = "/Users/andrew/Projects/Tools/GraphicsDojo/webcapture/webcapture #{url} -o #{full_path}"
  command = "export DISPLAY=:0; /var/www/apps/screenshot/bin/webcapture #{url} -o #{full_path}"
  command = "export DISPLAY=:0; #{options.root.to_s}/../bin/webcapture #{url} -o #{full_path}"

  puts File.dirname(__FILE__)
  puts command
  system( command )
  
  return full_path
end

def get_from_cache_or_put_from_block(key, expiry = 0)
  start_time = Time.now
  value = CACHE.get key
  elapsed = Time.now - start_time
  if value.nil? and block_given? then
    value = yield
    CACHE.add key, value, expiry
  end
  value
rescue MemCache::MemCacheError => err
  if block_given? then
    value = yield
    CACHE.put key, value, expiry
  end
  value
end

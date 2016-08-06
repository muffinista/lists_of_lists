#!/usr/bin/env ruby

require 'rubygems'
require 'chatterbot/dsl'

require 'wikipedia'
require "open-uri"
require 'tempfile'

SOURCE = "lists.txt"


#
# this is the script for the twitter bot lists_of_lists
# generated on 2016-08-04 16:45:19 -0400
#

#
# Hello! This is some starter code for your bot. You will need to keep
# this file and lists_of_lists.yml together to run your bot. The .yml file
# will hold your authentication credentials and help track certain
# information about what tweets the bot has seen so far.
#
# The code here is a basic starting point for a bot. It shows you the
# different methods you can use to get tweets, send tweets, etc. It
# also has a few settings/directives which you will want to read
# about, and comment or uncomment as you see fit.
#


def save_to_tempfile(url)
  uri = URI.parse(url)
  ext = [".", uri.path.split(/\./).last].join("")

  dest = File.join "/tmp", Dir::Tmpname.make_tmpname(['list', ext], nil)

  puts "#{url} -> #{dest}"

  open(dest, 'wb') do |file|
    file << open(url).read
  end

  # if the image is too big, let's lower the quality a bit
  if File.size(dest) > 5_000_000
    `mogrify -quality 65% #{dest}`
  end


  dest
end

def filter_images(list)
  list.reject { |l| l =~ /.svg$/ }
end


# Enabling **debug_mode** prevents the bot from actually sending
# tweets. Keep this active while you are developing your bot. Once you
# are ready to send out tweets, you can remove this line.
#debug_mode

# Chatterbot will keep track of the most recent tweets your bot has
# handled so you don't need to worry about that yourself. While
# testing, you can use the **no_update** directive to prevent
# chatterbot from updating those values. This directive can also be
# handy if you are doing something advanced where you want to track
# which tweet you saw last on your own.
#no_update

# remove this to get less output when running your bot
#verbose

# The blocklist is a list of users that your bot will never interact
# with. Chatterbot will discard any tweets involving these users.
# Simply add their twitter handle to this list.
blocklist "abc", "def"

# If you want to be even more restrictive, you can specify a
# 'safelist' of accounts which your bot will *only* interact with. If
# you uncomment this line, Chatterbot will discard any incoming tweets
# from a user that is not on this list.
# safelist "foo", "bar"

# Here's a list of words to exclude from searches. Use this list to
# add words which your bot should ignore for whatever reason.
exclude "hi", "spammer", "junk"

# Exclude a list of offensive, vulgar, 'bad' words. This list is
# populated from Darius Kazemi's wordfilter module
# @see https://github.com/dariusk/wordfilter
exclude bad_words

bot.config[:index] ||= 0

if ENV["FORCE_INDEX"]
  bot.config[:index] = ENV["FORCE_INDEX"].to_i
end

 
data = File.read(SOURCE).split(/\n/)

source = data[ bot.config[:index] ]
puts source

# use the original page title from our list to get the title we want
# to tweet out. we do this because there's a pretty solid chance that
# it will be a redirect to another page that isn't a "List of..."
tweet_title = source.gsub(/_/, " ")

page = Wikipedia.find( source )
puts page.title

opts = {}

if page.image_urls && ! page.image_urls.empty?
  puts page.image_urls.inspect
  
  image_url = filter_images(page.image_urls).sample
  
  puts image_url
  if image_url && image_url != ""
    opts[:media] = save_to_tempfile(image_url)
  end
end
  
output = [ tweet_title, page.fullurl ].join("\n")

begin
  tweet(output, opts)
rescue Exception => e
  puts e.inspect
end

bot.config[:index] += 1

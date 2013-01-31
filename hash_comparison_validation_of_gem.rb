#!/usr/bin/env ruby
#
# This script will compare the hash of a local rubygem to the hash of the remote
# gem at RubyGems.org. It is meant as a way to manually validate gems for gem authors.
#
# Usage:
#   ruby validate_original_gem.rb /path/to/gem/gemname.gem
#
# This will download an archived text file that contains SHA512 hashes for the remote gems.
# The author's hash of the gem will be validated against that file, where their gem is found.
#

require 'openssl'
require 'digest/sha1'
require 'zlib'

module Verify
  class Gem
    attr_reader :gem, :gem_basename, :rubygems_hash_file
    def initialize(gem)
      @gem = gem
      @gem_basename = File.basename(gem)
      @rubygems_hash_file = "rubygems-shas.txt"
    end

    def validate
      raise "Could not find your Gem" unless @gem_basename
      fetch_shas("http://cl.ly/MYie/download/rubygems-shas.txt.gz")
      verify_hashes
    end

    private

    def fetch_shas(file)
      return if File.exists?(rubygems_hash_file)

      `wget #{file}`
      Zlib::GzipReader.open(File.basename(file)) do |gz|
        File.open(rubygems_hash_file, 'w') do |file|
          file.write(gz.read)
        end
      end
    end

    def remote_hash
      open(rubygems_hash_file) { |f| f.grep(/#{gem_basename}/) }.first.split(' ').first.strip
    rescue
      raise "Doesn't look like your gem is there.\n#{failure_message}"
    end

    def local_hash
      Digest::SHA512.file(gem).to_s
    end

    def verify_hashes
      puts "Gem compared: #{gem_basename}"
      puts "  Remote hash: #{remote_hash}"
      puts "  Local hash:  #{local_hash}"
      if remote_hash == local_hash
        puts "Overall result: #{passed}"
      else
        puts "Overall result: #{failed}"
        puts failure_message
      end
    end

    def passed
      "\033[1;36mPASS\033[0m"
    end

    def failed
      "\033[1;31mFAIL\033[0m"
    end

    def failure_message
      "Try checking out the RubyGems incident Doc and use the unpack script: https://github.com/bradland/rubygems-incident-verifiers"
    end


  end
end
Verify::Gem.new(ARGV[0]).validate

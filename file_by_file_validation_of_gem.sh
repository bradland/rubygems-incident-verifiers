#!/usr/bin/env ruby
require 'tmpdir'
require 'pathname'
require 'open-uri'
require 'digest/sha2'

# This script compares a local rubygem archive file-by-file against the public
# version on S3 and is intended to aid gem owners in the manual validation of
# their gems.
#
# It can be used like so:
#
# ./file_by_file_validation_of_gem.sh path/to/local.gem
#
# it will unpack both the local gem which is specified as an argument and
# the remote gem, and compare each file, ensuring 1) that their contents
# are the same and 2) no files are contained in the public gem that are
# not also in the local gem.
#
# Prepared according to the gem owner verification instructions found here:
# https://docs.google.com/document/d/1fBD2J0yaNcXMUeU66hN-cEolkREWwDDUWWpnqrStDZU/edit#
#
# --cowboyd Jan 31 2013

class Verification
  def run!
    setup_directories!
    remote_gem.download!
    remote_gem.unpack!
    local_gem.copy!
    local_gem.unpack!
    remote_gem.each_file do |file|
      if local_gem.missing_file? file
        orphaned file
      elsif local_gem.sha512_hexdigest(file) == remote_gem.sha512_hexdigest(file)
        passed file
      else
        failed file
      end
    end
    report_results!
  end

  attr_reader :local_gem, :remote_gem

  def initialize
    @tmpdir = File.join Dir.tmpdir, 'gem-verification', File.basename(archive_name, '.gem')
    @local_gem = LocalGem.new self, File.join(@tmpdir, 'local')
    @remote_gem = RemoteGem.new self, File.join(@tmpdir, 'remote')
    @verified = true
  end

  def archive_name
    File.basename gem_path
  end

  def gem_path
    unless @gem_path
      @gem_path = File.expand_path ARGV[0], File.dirname(__FILE__)
      fail "#{ARGV[0]} does not exist!" unless File.exists? @gem_path
    end
    @gem_path
  end

  def passed(path)
    puts "  #{path} - [pass]"
  end

  def failed(path)
    @verified = false
    puts "  #{path} - [fail]"
  end

  def orphaned(path)
    @verified = false
    puts "  #{path} - REMOTE ORPHAN"
  end

  def log(msg)
    puts msg
  end

  def report_results!
    puts
    puts "Overall result: #{@verified ? 'PASS' : 'FAIL'}"
  end

  def setup_directories!
    log "using tmpdir #{@tmpdir}"
    FileUtils.rm_rf @tmpdir
    FileUtils.mkdir_p @local_gem.workdir
    FileUtils.mkdir_p @remote_gem.workdir
  end
end

module GemHandle
  attr_reader :verification, :workdir
  def initialize(verification, workdir)
    @verification = verification
    @workdir = Pathname(workdir)
  end

  def archive_name
    @verification.archive_name
  end

  def archive_file
    @workdir.join "#{archive_name}"
  end

  def root_directory
    @workdir.join File.basename(archive_name, '.gem')
  end

  def missing_file? path
    !root_directory.join(path).exist?
  end

  def sha512_hexdigest path
    Digest::SHA512.hexdigest File.read(root_directory.join path)
  end

  def unpack!
    Dir.chdir workdir do
      `gem unpack #{archive_file}`
    end
  end

  def each_file
    verification.log 'File compared:'
    Dir.chdir root_directory do
      Dir["**/*"].each do |path|
        yield path if File.file? path
      end
    end
  end
end

class LocalGem
  include GemHandle

  def copy!
    FileUtils.cp verification.gem_path, archive_file
  end
end

class RemoteGem
  include GemHandle

  def download!
    url = "http://production.cf.rubygems.org/gems/#{archive_name}"
    @verification.log "downloading #{url}"
    File.open archive_file, "w" do |f|
      open(url) do |res|
        res.each_line do |line|
          f.write line
        end
      end
    end
  end
end

Verification.new.run!

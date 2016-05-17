require 'rubygems'
require 'bundler/setup'

require 'optparse'
require 'set'

GEM_NAME = /[a-zA-Z0-9_-]+/
SPECIFIC_GEM_VERSION = /[0-9]+\.[0-9]+\.[0-9]+(\.[a-zA-Z0-9_-]+)?/

def parse_file(options = {}, git_compare_options = {})

  # Now we can use the options hash however we like.
  puts "Examining #{ options[:file] }" if options[:file]

  @all_changed_gems = Set.new
  removed_gems = {}
  added_gems = {}
  file_under_examination = nil
  IO.foreach(options[:file]) do |line|
    case line
      when /^(diff .*)$/
        if ($1 =~ /^diff --git a\/(.*)Gemfile.lock b\/((\1)Gemfile.lock)/)
          file_under_examination = $2
          puts line
        elsif file_under_examination
          compare_gems(removed_gems, added_gems, git_compare_options)
          file_under_examination = nil
          removed_gems = {}
          added_gems = {}
        end
      when /^\-\s+(#{GEM_NAME}) \((#{SPECIFIC_GEM_VERSION})\)/
        if file_under_examination
          # print "gem #{$1} version #{$2} removed: ", line
          removed_gems[$1] = $2
        end
      when /^\+\s+(#{GEM_NAME}) \((#{SPECIFIC_GEM_VERSION})\)/
        if file_under_examination
          # print "gem #{$1} version #{$2} added: ", line
          added_gems[$1] = $2
        end
    end
  end

  if file_under_examination
    compare_gems(removed_gems, added_gems, git_compare_options)
  end
end

def compare_gems(removed_gems={}, added_gems={}, git_compare_options={})
  puts "removed_gems: #{removed_gems.keys - added_gems.keys}"
  puts "added_gems: #{added_gems.keys - removed_gems.keys}"
  changed_gems = {}
  removed_gems.each do |gem_name, old_gem_version|
    changed_gems[gem_name] = {'old' => old_gem_version, 'new' => added_gems[gem_name]} if added_gems.has_key?(gem_name)
  end
  puts "changed_gems: #{changed_gems.keys}"

  changed_gems.each do |gem_name, h|
    compare_gem(gem_name, h['old'], h['new'], git_compare_options)
  end
end

def compare_gem(gem_name, old_gem_version, new_gem_version, git_compare_options)
  cmd = "gem compare #{gem_name} #{old_gem_version} #{new_gem_version} #{git_compare_options}"
  puts cmd

  if @all_changed_gems.include?(cmd)
    puts "(already compared this earlier)"
    return
  end
  @all_changed_gems.add(cmd)
  system cmd
end

if ENV['GEM_COMPARE_SOURCES']
  cmd = "gem sources --add #{ENV['GEM_COMPARE_SOURCES']}"
  puts cmd
  system cmd
end

options = {}
options_parser = OptionParser.new do |parser|
  parser.on("-f", "--file FILENAME", "The name of the Pull Request diff file to examine.") do |v|
    options[:file] = v
  end
  parser.on("--", "The rest of options will be passed on to git compare.") do |v|
    # no-op here
  end
end

both_args = $*.join(" ").split(" -- ")
options_parser.parse!(both_args[0].split(' '))
git_compare_options = both_args[1]

parse_file(options, git_compare_options)

if ENV['GEM_COMPARE_SOURCES']
  cmd = "gem sources --remove #{ENV['GEM_COMPARE_SOURCES']}"
  puts cmd
  system cmd
end

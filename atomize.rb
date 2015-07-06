#!/usr/bin/env ruby

=begin

    atomize-snippets, version 0.1
    The MIT License
    Copyright (c) 2015 Jan T. Sott
    
=end

require "builder"
require "json"

# Configuration
to_subfolder        = true
delete_completions  = false

# Snippets are created based on trigger-names. Here you define which characters
# you want to filter before creating a snippet file
trigger_filter = []

# Define which characters you want to substitute in the snippet
contents_filter = []

meta_info = <<-EOF
\natomize-snippets, version 0.1
The MIT License
Copyright (c) 2015 Jan T. Sott
EOF

# Methods
def write_snippet(dir, name, scope, trigger, contents)

    scope = '.'+scope
    
    # Create object
    completions = {
        # :generator => "http://github.com/idleberg/sublime-tinkertools",
        scope => {
            trigger => {
                :prefix => trigger,
                :body => contents
                }
            }
        }

    # Write to JSON
    puts "Writing \"#{name}.json\""
    File.open('_output/'+dir+'/'+name+'.json',"w") do |f|
      f.write(JSON.pretty_generate(completions))
    end
end

def filter_str(input, filter)
    filter.each do |needle, replacement|
        input = input.to_s.gsub(needle, replacement)
    end
    return input
end

puts meta_info

# Get output name from argument
if ARGV.count > 1 
    puts "\nError: Too many arguments passed (#{ARGV.count})"
    exit
elsif ARGV.count == 0
    input = "*.sublime-completions"
else 
    input = ARGV[0]
    unless input.end_with? ".sublime-completions"
        input += ".sublime-completions"
    end
end


input_counter  = 0
output_counter = 0

# Iterate over completions in current directory
Dir.glob(input) do |item|

    puts "\nReading \"#{item}\""

    json = File.read(item)
    parsed = JSON.load(json)

    scope = parsed["scope"]

    # Iterate over completions in JSON
    parsed["completions"].each do |line|
        trigger  = line['trigger']
        contents = line['contents'].to_s

        # Break if empty
        next if trigger.to_s.empty? || contents.to_s.empty?

        # Run filters
        output = filter_str(trigger, trigger_filter)
        contents = filter_str(contents, contents_filter)

        # Set target directory
        if to_subfolder == true
            dir = File.basename(item, ".*")

            unless Dir.exists?('_output/'+dir)
                Dir.mkdir('_output/')
                Dir.mkdir('_output/'+dir)
            end
        else
            dir = "."
        end

        name = trigger.gsub(/[^0-9a-z# \.\(\)_-]/i, '')

        write_snippet(dir, name, scope, trigger, contents)

        output_counter += 1
    end

    # Delete completions
    if delete_completions == true
        puts "x Deleting \"#{item}\""
        File.delete(item)
    end

    input_counter += 1
end

# Game Over
if input_counter == 0
    puts "\nError: No files found"
elsif input_counter == 1
     puts "\nConverted #{input_counter} file into #{output_counter}"
else
    puts "\nConverted #{input_counter} files into #{output_counter}"
end
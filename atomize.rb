#!/usr/bin/env ruby

$version = "0.2.1"

# require "builder"
require "json"
require "nokogiri"
require "optparse"

# Snippets are created based on trigger-names. Here you define which characters
# you want to filter before creating a snippet file
trigger_filter = []

# Define which characters you want to substitute in the snippet
contents_filter = []

$input_counter  = 0
$output_counter = 0

meta_info = <<-EOF
\natomize-snippets, version #{$version}
The MIT License
Copyright (c) 2015 Jan T. Sott
EOF

# Methods
def read_xml(item)
    puts "\nReading snippet file '#{item}'"

    file = File.read(item)
    xml = Nokogiri::XML(file)

    return xml
end

def read_json(item)
    puts "\nReading completion file '#{item}'"

    file = File.read(item)
    json = JSON.load(file)

    return json
end

def get_xml_scope(xml)
    scope = ""

    if $scope == nil
        scope += "."
        scope += xml.xpath("//scope")[0].text.strip
        puts "Using default scope '"+scope+"'"
    else
        if $scope[0] != "."
            scope += "."
        end
        scope += $scope
        puts "Override scope using '"+scope+"'"
    end

    return scope
end

def get_json_scope(json)
    scope = ""

    if $scope == nil
        scope += "+"
        scope += json["scope"]
        puts "Using default scope '"+scope+"'"
    else
        if $scope[0] != "."
            scope += "."
        end
        scope += $scope
        puts "Override scope using '"+scope+"'"
    end

    return scope
end

def json_to_cson(json)

    scope = get_json_scope(json)
    
    cson = "'"+scope+"':\n"
    
    json["completions"].each do |line|
        trigger = line["trigger"]
        contents = line["contents"]

        cson += "  '"+trigger+"':\n"
        cson += "    'prefix': '"+trigger+"'\n"
        cson += "    'body': '"+contents+"'\n"
    end

    return cson
end

def json_to_many_cson(json)

    scope = get_json_scope(json)
    
    cson = "'"+scope+"':\n"
    
    json["completions"].each do |line|
        trigger = line["trigger"]
        contents = line["contents"]

        cson += "  '"+trigger+"':\n"
        cson += "    'prefix': '"+trigger+"'\n"
        cson += "    'body': '"+contents+"'\n"

        puts "Writing #{trigger}.cson"
        File.open("./_output/"+trigger+".cson","w") do |f|
            f.write(cson)
        end
    end

    return cson
end

def json_to_many_json(json)

    scope = get_json_scope(json)
    
    json["completions"].each do |line|
        
        trigger = line["trigger"]
        contents = line["contents"]

        # Create object
        json = {
            scope => {
                trigger => {
                    :prefix => trigger,
                    :body => contents
                }
            }
        }

        puts "Writing #{trigger}.json"
        File.open('_output/'+trigger+'.json',"w") do |f|
          f.write(JSON.pretty_generate(json))
        end
    end

    return json
end

def xml_to_cson(xml)
    
    scope = get_xml_scope(xml)

    if $input_counter == 0
        cson = "'"+scope+"':\n"
    end

    trigger = xml.xpath("//tabTrigger")[0].text.strip

    xml.xpath("//content").each do |node|
        contents = node.text.strip
        # contents = contents_s.gsub("'", nil)
        cson += "  '"+trigger+"':\n"
        cson += "    'prefix': '"+trigger+"'\n"
        if contents.lines.count <= 1
            cson += "    'body': '"+contents+"'\n"
        else
            cson += "    'body': \"\"\"\n"
            contents.each_line do |line|
                cson += "      "+line
            end
            cson +="\n    \"\"\"\n"
        end
    end

    return cson
end

def xml_to_json(xml)

    scope = get_xml_scope(xml)

    trigger = xml.xpath("//tabTrigger")[0].text.strip
    contents = xml.xpath("//content")[0].text.strip
    
    # Create object
    json = {
        scope => {
            trigger => {
                :prefix => trigger,
                :body => contents
            }
        }
    }

    return json
end

def filter_str(input, filter)
    filter.each do |needle, replacement|
        input = input.to_s.gsub(needle, replacement)
    end
    return input
end

# default options
$scope = nil
$merge = false
$split = false

args = ARGV.count
 
# parse arguments
ARGV.options do |opts|
    opts.banner = "\nUsage: atomize.rb [options]"

    opts.on("-h", "--help", "prints this help") do
        puts meta_info
        puts opts
        exit
    end

    opts.on("--input=<file>", String, "Input file") {
        |input| $input = input
    }

    opts.on("--output=<file>", String, "Output file") {
        |output| $output = output
    }

    # opts.on("-m", "--merge", "merge results into single file") {
    #     if $split != true
    #         $merge = true
    #     else
    #         abort("Error: You can't merge AND split")
    #         # exit
    #     end
    # }

    opts.on("-s", "--split", "splits result in single files") {
        if $merge != true
            $split = true
        else
            abort("Error: You can't split AND merge")
            # exit
        end
    }

    opts.on("--scope=<scope>", String, "overwrite scope") {
        |val| $scope = val
    }

    opts.on_tail("-v", "--version", "show version") do
        puts $version
        exit
    end

    opts.parse!
end

# let's go
puts meta_info

if args < 1
    puts meta_info
    abort("\nError: no arguments passed")
end 

if  ($input.end_with? ".sublime-completions") || ($input.end_with? ".json")

    Dir.glob($input) do |item|
        json = read_json(item)

        if $split == true
            if $output == "cson"
                json_to_many_cson(json)
            else $output == "json"
                json_to_many_json(json)
            end
        else
            cson = json_to_cson(json)

            # match output file to input basename
            if $output == "cson"
                $output = File.basename($input, ".*")+".cson"
            end
            
            puts "Writing '#{$output}'"
            File.open("./_output/"+$output,"w") do |f|
                f.write(cson)
            end
        end

        $input_counter += 1
        $output_counter += 1
    end

elsif ($input.end_with? ".sublime-snippet") || ($input.end_with? ".xml")

    Dir.glob($input) do |item|

        xml = read_xml(item)

        if ($output.end_with? ".cson") || ($output == "cson")
            cson = xml_to_cson(xml)
            
            # match output file to input basename
            if $output == "cson"
                $output = File.basename($input, ".*")+".cson"
            end

            puts "Writing '#{$output}'"
            File.open("./_output/"+$output,"w") do |f|
                f.write(cson)
            end

        elsif ($output.end_with? ".json") || ($output == "json")
            json = xml_to_json(xml)
            
            # match output file to input basename
            if $output == "json"
                $output = File.basename($input, ".*")+".json"
            end

            puts "Writing '#{$output}'"
            File.open("./_output/"+$output,"w") do |f|
                f.write(JSON.pretty_generate(json))
            end         
        end

        $input_counter += 1
        $output_counter += 1
    end
else
    puts "\nError: Unknown file passed (#{$input})"
end

# Game Over
if $input_counter == 0
    puts "\nNo files converted"
elsif $input_counter == 1
     puts "\nConverted #{$input_counter} file"
else
    puts "\nConverted #{$input_counter} files"
end
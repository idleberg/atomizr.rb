#!/usr/bin/env ruby

$version = "0.3.0"

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

def get_outname(type, item)
    if $output == type
        if ($input.start_with? "*.") || (($input.end_with? ".*"))
            file = item
        else
            file = $input
        end
        output = File.basename(file, ".*")+"."+type
    else
        output = $output
    end

    return output
end

def get_scope(data, mode)
    scope = ""

    if $scope == nil
        scope += "."
        if mode == 'xml'
            scope += data.xpath("//scope")[0].text.strip
        elsif mode == 'json'
            scope += data["scope"]
        end
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

def json_to_cson(json, many = false)

    scope = get_scope(json, 'json')
    
    cson = "'"+scope+"':\n"
    
    json["completions"].each do |line|
        trigger = line["trigger"]
        contents = line["contents"]

        cson += "  '"+trigger+"':\n"
        cson += "    'prefix': '"+trigger+"'\n"
        cson += "    'body': '"+contents+"'\n"
    end

    if many == true
        puts "Writing '#{trigger}.cson'"
        File.open("./_output/"+trigger+".cson","w") do |f|
            f.write(cson)
        end
    end

    return cson
end

def json_to_json(json, many = false)

    scope = get_scope(json, 'json')
    
    json["completions"].each do |line|
        
        trigger = line["trigger"]
        contents = line["contents"]

        # Create object
        file = {
            scope => {
                trigger => {
                    'prefix' => trigger,
                    'body' => contents
                }
            }
        }

        if many == true
            puts "Writing '#{trigger}.json'"
            File.open('_output/'+trigger+'.json',"w") do |f|
              f.write(JSON.pretty_generate(file))
            end
        else
            return file
        end
    end

end

def xml_to_cson(xml)
    
    scope = get_scope(xml, 'xml')

    cson = "'"+scope+"':\n"
    
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

    scope = get_scope(xml, 'xml')

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
$array = []

args = ARGV.count
 
# parse arguments
ARGV.options do |opts|
    opts.banner = "\nUsage: atomize.rb [options]"

    opts.on("-h", "--help", "prints this help") do
        puts meta_info
        puts opts
        exit
    end

    opts.on("--input=<file>", String, "Input file(s)") {
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
    abort("\nError: no arguments passed")
end

if  ($input.end_with? ".sublime-completions") || ($input.end_with? ".json")

    Dir.glob($input) do |item|
        json = read_json(item)

        if $split == true
            if $output == "cson"
                json_to_cson(json, true)
            else $output == "json"
                json_to_json(json, true)
            end
        else
            if ($output.end_with? ".cson") || ($output == "cson")
                data = json_to_cson(json)
                output = get_outname('cson', item)
                
                puts "Writing '#{output}'"
                File.open("./_output/"+output,"w") do |f|
                    f.write(data)
                end

            elsif ($output.end_with? ".json") || ($output == "json")
                data = json_to_json(json)
                output = get_outname('json', item)

                puts "Writing '#{output}'"
                File.open('_output/'+output,"w") do |f|
                  f.write(JSON.pretty_generate(data))
                end
            end
        end

        $input_counter += 1
        $output_counter += 1
    end

elsif ($input.end_with? ".sublime-snippet") || ($input.end_with? ".xml")

    # scope = nil
    # completions = Array.new

    Dir.glob($input) do |item|

        xml = read_xml(item)

        # if $merge == true
        #     # if $output == "cson"
        #     #     json_to_cson(json, true)
        #     # else $output == "json"
        #     #     json_to_json(json, true)
        #     # end
        #     if $input_counter == 0
        #         scope = get_scope(xml, 'xml')
        #         completions << scope
        #     end
        #     trigger = xml.xpath("//tabTrigger")[0].text.strip
        #     contents = xml.xpath("//content")[0].text.strip

        #     completions << {
        #         trigger => {
        #             :prefix => trigger,
        #             :body => contents
        #         }
        #     }
        # else
            if ($output.end_with? ".cson") || ($output == "cson")
                cson = xml_to_cson(xml)
                output = get_outname('cson', item)

                puts "Writing '#{output}'"
                File.open("./_output/"+output,"w") do |f|
                    f.write(cson)
                end

            elsif ($output.end_with? ".json") || ($output == "json")
                json = xml_to_json(xml)
                
                # match output file to input basename
                if $output == "json"
                    if ($input.start_with? "*.") || (($input.end_with? ".*"))
                        file = item
                    else
                        file = $input
                    end
                    output = File.basename(file, ".*")+".json"
                end


                puts "Writing '#{output}'"
                File.open("./_output/"+output,"w") do |f|
                    f.write(JSON.pretty_generate(json))
                end         
            end
        end


        $input_counter += 1
        $output_counter += 1
    # end

    # if $merge == true
    #     output = $output

    #     puts "Writing '#{output}'"
    #     File.open("./_output/"+output,"w") do |f|
    #         f.write(JSON.pretty_generate(completions))
    #     end   
    # end
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
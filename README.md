# Atomizr

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg?style=flat-square)](http://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/idleberg/atomizr.svg?style=flat-square)](https://github.com/idleberg/atomizr/releases)

A Ruby script to convert [Sublime Text](http://www.sublimetext.com/) snippets and completions (and TextMate snippets) into [Atom](http://atom.io) snippets

## Installation

1. Clone the repository `git clone https://github.com/idleberg/atomizr.git`
2. Change directory `cd atomizr`
3. Install Gems using [Bundler](http://bundler.io/) `bundle install`
4. *Optional*: make `atomizr` executable `chmod +x atomizr`

## Usage

As a shorthand to `ruby atomizr [options]`, you can set `chmod +x atomizr` and run the script as `atomizr [options]`.

### Standard conversion

Examples:

```bash
# Grab a random Sublime Text package
git clone https://github.com/idleberg/AppleScript-Sublime-Text AS

# Usage: atomizr --input=<file> --output=<file> [options]

# Convert completions into CSON
./atomizr --input=AS/AppleScript.sublime-completions --output=completions.cson

# Again, this time to JSON, and using shorthands
./atomizr -i AS/AppleScript.sublime-completions -o completions.json

# Convert completions, one file per completion
./atomizr -i AS/AppleScript.sublime-completions -o cson --split

# Convert snippets, merge into one file.
# Put wildcard in quotes!
./atomizr -i "AS/snippets/*.sublime-snippet" -o snippets.cson --merge
```

For all available options, see `--help` for details

### TextMate bundles

Since apm conversion of TextMate bundles requires a specific folder structure, you can use Atomizr to bundle and convert these files.

Example:

```bash
# Grab a random TextMate bundle
git clone https://github.com/jashkenas/coffee-script-tmbundle CoffeeScript.tmBundle

# Organize files, convert and delete bundle
./atomizr -i CoffeeScript.tmBundle -o atom-language-coffeescript -X
```

## Filters

In the header of the script, you can define arrays for replacement operations. Filters can be defined for file-name and snippet title, prefix and body.

```bash
# replace characters in file-name
@filename_filter =  [
    [/[\x00\/\\:\*\?\"\$<>\|]/, "_"],
    ["\t",  "-"]
]
```

## License

This work is licensed under the [The MIT License](LICENSE.md).

## Donate

You are welcome support this project using [Flattr](https://flattr.com/submit/auto?user_id=idleberg&url=https://github.com/idleberg/atomizr) or Bitcoin `17CXJuPsmhuTzFV2k4RKYwpEHVjskJktRd`
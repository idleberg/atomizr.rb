# Atomizr

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg?style=flat-square)](http://opensource.org/licenses/MIT)
[![Gem](https://img.shields.io/gem/v/atomizr.svg?style=flat-square)](https://rubygems.org/gems/atomizr)
[![GitHub release](https://img.shields.io/github/release/idleberg/ruby-atomizr.svg?style=flat-square)](https://github.com/idleberg/atomizr.rb/releases)
[![Gem](https://img.shields.io/gem/dt/atomizr.svg?style=flat-square)](https://rubygems.org/gems/atomizr)

A command-line tool to convert [Sublime Text](http://www.sublimetext.com/) snippets and completions, as well as TextMate snippets, into [Atom](http://atom.io) snippets.

Also available as packages for [Atom](https://github.com/idleberg/atom-atomizr) and [Sublime Text](https://github.com/idleberg/sublime-atomizr).

## Installation

`gem install atomizr`

## Usage

### Standard conversion

Examples:

```bash
# Grab a random Sublime Text package
git clone https://github.com/idleberg/AppleScript-Sublime-Text AS

# Usage: atomizr --input=<file> --output=<file> [options]

# Convert completions into CSON
atomizr --input=AS/AppleScript.sublime-completions --output=applescript.cson

# Again, this time to JSON, and using shorthands
atomizr -i AS/AppleScript.sublime-completions -o applescript.json

# Convert completions, one file per completion
atomizr -i AS/AppleScript.sublime-completions -o cson --split

# Convert snippets, merge into one file.
# Put wildcard in quotes!
atomizr -i "AS/snippets/*.sublime-snippet" -o snippets.cson --merge
```

For all available options, see `--help` for details

### TextMate bundles

Since apm conversion of TextMate bundles requires a specific folder structure, you can use Atomizr to bundle and convert these files.

Example:

```bash
# Grab a random TextMate bundle
git clone https://github.com/jashkenas/coffee-script-tmbundle CoffeeScript.tmBundle

# Organize files, convert and delete bundle
atomizr -i CoffeeScript.tmBundle -o atom-language-coffeescript -X
```

## License

This work is licensed under the [The MIT License](LICENSE.md).

## Donate

You are welcome support this project using [Flattr](https://flattr.com/submit/auto?user_id=idleberg&url=https://github.com/idleberg/atomizr.rb) or Bitcoin `17CXJuPsmhuTzFV2k4RKYwpEHVjskJktRd`

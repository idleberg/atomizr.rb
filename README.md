# Atomize Snippets

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg?style=flat-square)](http://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/idleberg/atomize-snippets.svg?style=flat-square)](https://github.com/idleberg/atomize-snippets/releases)

A Ruby script to convert [Sublime Text](http://www.sublimetext.com/) snippets and completions into [Atom](http://atom.io) snippets

## Installation

1. Clone the repository `git clone https://github.com/idleberg/atomize-snippets.git`
2. Change directory `cd atomize-snippets.git`
3. Install Gems using [Bundler](http://bundler.io/) `bundle install`

## Usage

You might have to `chmod +x atomize` the first time. Otherwise, simply use `ruby atomize [options]`.

```bash
# Convert snippet or completions
./atomize --input=<file> --output=<file> [options]

# Convert file into CSON
./atomize --input=<file> --output=<file>.cson

# Convert file into JSON
./atomize --input=<file> --output=<file>.json

# Convert completions, save as multiple CSON files
./atomize --input=<file>.sublime-completions --output=cson --split

# Use quotes to convert multiple files at once
./atomize --input="snippets/*" --output=cson

# Override scope
./atomize --input=<file> --output=<file> --scope=.text.html
```

See `./atomize --help` for details

## License

The MIT License (MIT)

Copyright (c) 2015 Jan T. Sott

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Donate

You are welcome support this project using [Flattr](https://flattr.com/submit/auto?user_id=idleberg&url=https://github.com/idleberg/atomize-snippets) or Bitcoin `17CXJuPsmhuTzFV2k4RKYwpEHVjskJktRd`
# bb-parser 

[![Build Status](https://travis-ci.org/brunoald/bb-parser.svg?branch=master)](https://travis-ci.org/brunoald/bb-parser)
[![Coverage Status](https://coveralls.io/repos/github/brunoald/bb-parser/badge.svg?branch=master)](https://coveralls.io/github/brunoald/bb-parser?branch=master)

This software parses Banco do Brasil CSV statements and creates a better one.

## How to use it

- Install the dependencies with `bundle install`.
- Ensure everything works fine by running `bundle exec rspec`.
- Download your bank statement files from Banco do Brasil website.
- Add them into `data` folder.
- Run the command `bundle exec ruby run.rb`.
- Import the generated `output.csv` file into your favorite spreadsheet or data visualization software.

## License

GNU General Public License.

## Copyright

Copyright (c) 2016 Bruno Dias

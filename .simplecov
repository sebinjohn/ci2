require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.add_filter 'src/test/bash/wvtest.sh'
SimpleCov.add_filter "/src\/test/"

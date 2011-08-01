# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'test/unit'

require 'rubygems'
require 'bundler'

Bundler.setup

require 'mocha'
require 'shoulda'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'metior'
include Metior

# Extends TestCase functionality
class Test::Unit::TestCase

  # Provides a negative assertion that's easier on the eyes
  #
  # The assertion fails, if the given value is +true+.
  #
  # @param [true, false] boolean The value that should be +false+
  # @param [String] message The message that should be displayed
  def assert_not(boolean, message = '')
    assert !boolean, message
  end

end

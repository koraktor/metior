# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'helper'
require 'metior/registerable'

class TestRegisterable < Test::Unit::TestCase

  context 'A registerable component' do

    setup do
      module MockRegisterable
        extend Registerable
      end
    end

    should 'be able to register with Metior' do
      Metior.expects(:register).with(:reg_id, MockRegisterable)

      MockRegisterable.as :reg_id
    end

    should 'have an ID once registered' do
      Metior.stubs :register

      MockRegisterable.as :reg_id

      assert_equal :reg_id, MockRegisterable.id
    end

  end

end

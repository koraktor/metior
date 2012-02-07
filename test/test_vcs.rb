# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'helper'
require 'metior/vcs'

class TestVCS < Test::Unit::TestCase

  context 'The VCS module' do

    setup do
      @adapter = mock
      @adapter.stubs(:include?).with(VCS).returns false
      @adapter.stubs(:include?).with(Adapter).returns true
      Metior.register :mock, @adapter

      module MockVCS
        include VCS
        as :mock
        default_adapter :mock
      end
    end

    should 'provide an default adapter' do
      assert_equal @adapter, MockVCS.default_adapter
    end

    should 'allow an object of a specific VCS to access the VCS module' do
      object = Object.new
      object.extend MockVCS

      assert_equal MockVCS, object.vcs
    end

    teardown do
      Metior.module_exec { @@vcs_adapters.delete :mock }
      Metior.module_exec { @@vcs_types.delete :mock }
    end

  end

end

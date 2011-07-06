# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'
require 'metior/vcs'

module MockVCS
  NAME = :mock
  include VCS
  not_supported :some_feature
end
Metior.module_exec { @@vcs_types.delete :mock }

class TestVCS < Test::Unit::TestCase

  context 'The VCS module' do

    setup do
      Metior.module_exec { @@vcs_types[:mock] = MockVCS }

      @vcs_object = Object.new
      @vcs_object.extend MockVCS
    end

    should 'allow access to the features of a VCS' do
      assert_not MockVCS.supports? :some_feature
    end

    should 'automatically try to load the VCS implementation files' do
      MockVCS.expects(:require).with('metior/mock/actor').once
      MockVCS.expects(:require).with('metior/mock/commit').once
      MockVCS.expects(:require).with('metior/mock/repository').once

      begin
        MockVCS::Commit
      rescue NameError
      end
    end

    should 'allow an object of a specific VCS to access the VCS module' do
      assert_equal MockVCS, @vcs_object.vcs
    end

    should 'allow an object of a specific VCS to access the VCS features' do
      assert_not @vcs_object.supports? :some_feature
      begin
        @vcs_object.support! :some_feature
        assert false
      rescue
        assert_instance_of UnsupportedError, $!
        assert_equal "Operation not supported by the current VCS (:mock).", $!.message
      end
    end

    teardown do
      Metior.module_exec { @@vcs_types.delete :mock }
    end

  end

end

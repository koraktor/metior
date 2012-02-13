# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'helper'
require 'metior/adapter'

class TestAdapter < Test::Unit::TestCase

  context 'The Adapter module' do

    setup do
      @mock_vcs = mock
      @mock_vcs.stubs(:register_adapter).with :mock, anything
      Metior.stubs(:find_vcs).with(:mock).returns @mock_vcs
      module MockAdapter
        include Adapter
        as :mock
        register_for :mock
        not_supporting :some_feature
      end

      @adapter_object = Object.new
      @adapter_object.extend MockAdapter
    end

    should 'be registerable' do
      Adapter.include? Registerable
    end

    should 'allow access to the features of a VCS' do
      assert_not MockAdapter.supports? :some_feature
    end

    should 'automatically try to load the VCS implementation files' do
      MockAdapter.expects(:autoload).with(:Actor, 'metior/adapter/mock/actor').once
      MockAdapter.expects(:autoload).with(:Commit, 'metior/adapter/mock/commit').once
      MockAdapter.expects(:autoload).with(:Repository, 'metior/adapter/mock/repository').once

      begin
        MockAdapter::Commit
      rescue NameError
      end
    end

    should 'be able to register with a VCS' do
      mock_vcs = mock
      mock_vcs.expects(:register_adapter).with :mock, MockAdapter
      Metior.stubs(:find_vcs).with(:mock).returns mock_vcs
      MockAdapter.register_for :mock
    end

    should 'allow an object of a specific adapter to access the adapter module' do
      assert_equal MockAdapter, @adapter_object.adapter
    end

    should 'allow an object of a specific adapter to access the adapter features' do
      assert_not @adapter_object.supports? :some_feature
      begin
        @adapter_object.support! :some_feature
        assert false
      rescue
        assert_instance_of UnsupportedError, $!
        assert_equal 'Operation not supported by the current VCS adapter (:mock).', $!.message
      end
    end

    should 'allow an object of a specific adapter to acces the VCS' do
      assert_equal @mock_vcs, @adapter_object.vcs
    end

    teardown do
      Metior.module_exec { @@vcs_types.delete :mock }
    end

  end

end

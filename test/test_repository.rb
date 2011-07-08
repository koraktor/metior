# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'

class TestRepository < Test::Unit::TestCase

  context 'The base class for Metior VCS repositories' do

    setup do
      require 'metior/repository'

      @repo = Metior::Repository.new('dummy')
    end

    should 'load the description of the project on demand' do
      @repo.expects(:load_description).once
      @repo.description
    end

    should 'load the name of the project on demand' do
      @repo.expects(:load_name).once
      @repo.name
    end

    should 'not implement the #id_for_ref method' do
      assert_raise NotImplementedError do
        @repo.send :id_for_ref, nil
      end
    end

    should 'not implement the #load_branches method' do
      assert_raise NotImplementedError do
        @repo.send :load_branches
      end
    end

    should 'not implement the #load_commits method' do
      assert_raise NotImplementedError do
        @repo.send(:load_commits, nil)
      end
    end

    should 'not implement the #load_description' do
      assert_raise NotImplementedError do
        @repo.send :load_description
      end
    end

    should 'not implement the #load_name method' do
      assert_raise NotImplementedError do
        @repo.send :load_name
      end
    end

    should 'not implement the #load_tags method' do
      assert_raise NotImplementedError do
        @repo.send :load_tags
      end
    end

    should 'parse commit ranges correctly' do
      @repo.expects(:id_for_ref).with('master').times(3).returns('abc')
      @repo.expects(:id_for_ref).with('development').twice.returns('def')
      assert_equal 'abc'..'def', @repo.send(:parse_range, 'master'..'development')
      assert_equal 'abc'..'def', @repo.send(:parse_range, 'master..development')
      assert_equal ''..'abc', @repo.send(:parse_range, 'master')
    end

    should 'miss the cache when loading a different commit range' do
      @repo.expects(:id_for_ref).with('master').returns('abc')
      @repo.expects(:id_for_ref).with('HEAD').returns('abc')
      @repo.expects(:load_commits).twice.returns([nil, []])

      @repo.commits 'master'
      @repo.commits 'HEAD'
    end

  end

end

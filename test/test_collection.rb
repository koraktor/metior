# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'
require 'metior/collections/collection'

class TestCollections < Test::Unit::TestCase

  context 'A collection of objects' do

    setup do
      @collection = Collection.new
      @objects = Array.new(3) { mock }
      @objects.each_with_index { |o, i| o.stubs(:id).returns i+1 }
      @collection << @objects[0]
      @collection << @objects[1]
      @collection << @objects[2]
    end

    should 'have a simple constructor' do
      collection = Collection.new @objects
      assert_equal [1, 2, 3], collection.keys
      assert_equal @objects[0], collection[1]
      assert_equal @objects[1], collection[2]
      assert_equal @objects[2], collection[3]
    end

    should 'be a subclass of Hash' do
      assert_kind_of Hash, @collection
      assert_kind_of OrderedHash, @collection if RUBY_VERSION.match(/^1\.8/)
    end

    should 'have a working << operator' do
      object = mock :id => :x
      @collection << object
      assert_equal object, @collection[:x]
    end

    should 'have a working #each method' do
      objects = []
      result = @collection.each { |obj| objects << obj }
      assert_equal @collection, result
      assert_equal @objects, objects
    end

    should 'have a working #last method' do
      assert_equal @objects.last, @collection.last
    end

    should 'delegate support! to its first element' do
      @objects.first.expects(:support!).with :some_feature
      @collection.support! :some_feature
    end

  end

end

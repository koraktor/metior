# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'helper'
require 'metior/collections/collection'

class Dummy
    def id
      __id__
    end
end

class TestCollections < Test::Unit::TestCase

  context 'A collection of objects' do

    setup do
      @collection = Collection.new
      @object1 = Dummy.new
      @object2 = Dummy.new
      @object3 = Dummy.new
      @collection << @object1
      @collection << @object2
      @collection << @object3
    end

    should 'have a simple constructor' do
      collection = Collection.new [@object1, @object2, @object3]
      assert_equal [@object1.id, @object2.id, @object3.id], collection.keys
      assert_equal @object1, collection[@object1.id]
      assert_equal @object2, collection[@object2.id]
      assert_equal @object3, collection[@object3.id]
    end

    should 'be a subclass of Hash' do
      assert @collection.is_a? Hash
      assert @collection.is_a? OrderedHash if RUBY_VERSION.match(/^1\.8/)
    end

    should 'have a working << operator' do
      object = Dummy.new
      @collection << object
      assert_equal object, @collection[object.id]
    end

    should 'have a working #all? method' do
      assert @collection.all? { |obj| obj.is_a? Dummy }
      assert_not @collection.all? { |obj| obj == @object1 }
    end

    should 'have a working #first method' do
      assert_equal @object1, @collection.first
    end

    should 'have a working #last method' do
      assert_equal @object3, @collection.last
    end

  end

end

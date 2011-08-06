# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

HASH_CLASS = if RUBY_VERSION.match(/^1\.8/)
  require 'hashery/ordered_hash'
  OrderedHash
else
  Hash
end

module Metior

  # Represents a hash retaining insertion order
  #
  # On Ruby 1.9 this is a subclass of `Hash` because Ruby 1.9's hashes are
  # already retaining insertion order. For Ruby 1.8 this needs a special
  # parent class `OrderedHash` provided by the Hashery gem.
  #
  # Additionally, it provides some shortcuts to make its interface more
  # array-like.
  #
  # @author Sebastian Staudt
  # @see Hash
  # @see OrderedHash
  class Collection < HASH_CLASS

    # Creates a new collection with the given objects
    #
    # @param [Array<Object>] objects The objects that should be initially
    #        inserted into the collection
    def initialize(objects = [])
      super()

      objects.each { |obj| self << obj }
    end

    # Adds an object to this collection
    #
    # The object should provide a `#id` method to generate a key for this
    # object.
    #
    # @param [Object] object The object to add to the collection
    # @return [Collection] The collection itself
    # @see Array#<<
    def <<(object)
      self[object.id] = object
      self
    end

    # Evaluates the block for each element of the collection
    #
    # @return [Collection] The collection itself
    # @yield [element] Each of the elements of this collection
    # @yieldparam [Object] element The current element of the collection
    def each(&block)
      each_value(&block)
      self
    end

    # Returns the element that has been added last to this collection
    #
    # @return [Object] The last element of the collection
    # @see Enumerable#last
    def last
      values.last
    end

    if superclass != Hash
      # Adds all elements of another collection to this one
      #
      # @param [Collection] other_collection The collection to merge into this
      #        one
      # @return [Collection] The merged collection
      def merge!(other_collection)
        other_collection.each { |obj| self << obj }
        self
      end
    end

  end

end

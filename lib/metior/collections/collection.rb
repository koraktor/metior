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

    # Evaluates the block for each value of the collection and returns whether
    # the block returned `true` for all of them.
    #
    # @return [Boolean] Whether the block returns `true` for all values
    # @see Enumerable#all?
    def all?(&block)
      values.all?(&block)
    end

    # Returns the value that has been added first to this collection
    #
    # @return [Object] The first value of the collection
    # @see Array#first
    def first
      values.first
    end

    # Returns the value that has been added last to this collection
    #
    # @return [Object] The last value of the collection
    # @see Array#last
    def last
      values.last
    end

  end

end

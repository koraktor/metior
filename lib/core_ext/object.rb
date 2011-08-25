# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

# Provides several backports of Ruby 1.9 features for Ruby implementations not
# supporting them
#
# @author Sebastian Staudt
class Object

  unless Object.method_defined? :singleton_class

    # Returns the singleton class (also known as eigenclass) of this object
    #
    # @return [Class] The singleton class of this object
    def singleton_class
      class << self
         self
      end
    end

  end

  unless Object.method_defined? :respond_to_missing?

    # Returns whether this object responds to the given method
    #
    # @param [Symbol] name The name of the method that should be called
    # @param [Boolean] include_private If `true` includes private method in the
    #        lookup
    # @return [Boolean] `true` if the method is implemented or can be called
    #         dynamically
    # @see #respond_to_missing?
    def respond_to?(name, include_private = false)
      super || respond_to_missing?(name, include_private)
    end

    # Returns whether the object can respond to a method
    #
    # @param [Symbol] name The name of the method that should be called
    # @param [Boolean] include_private If `true` includes private method in the
    #        lookup
    # @return [Boolean] `true` if this object responds to this method via
    #         via method_missing
    # @see #method_missing
    # @see #respond_to?
    def respond_to_missing?(name, include_private = false)
      false
    end

  end

end

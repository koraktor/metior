# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

unless Object.method_defined? :singleton_class

  # Provides the +singleton_class+ method for Ruby implementations not
  # supporting it
  #
  # @author Sebastian Staudt
  class Object

    # Returns the singleton class (also known as eigenclass) of this object
    #
    # @return [Class] The singleton class of this object
    def singleton_class
      class << self
         self
      end
    end

  end

end

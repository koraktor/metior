# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior

  # This module should be included by all classes that have VCS implementation
  # specific subclasses, like {Repository}.
  #
  # @author Sebastian Staudt
  module AutoIncludeVCS

    # Will automatically include the class method `inherited`
    #
    # @see ClassMethods
    def self.included(mod)
      mod.extend ClassMethods
    end

    # This module implements the class method `inherited` that will handle the
    # automatic inclusion of the VCS implementation `Module`
    #
    # @author Sebastian Staudt
    module ClassMethods

      # This method will automatically include the VCS implementation `Module`
      # corresponding to the subclass that has just been defined
      #
      # @param [Class] subclass The subclass that has been defined
      def inherited(subclass)
        vcs = Object
        subclass.to_s.split('::')[0..-2].each do |mod|
          vcs = vcs.const_get mod.to_sym
        end
        subclass.send :include, vcs if vcs.ancestors.include? VCS
      end

    end

  end

end

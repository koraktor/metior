# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'metior/errors'

module Metior

  # This module provides functionality to automatically register new VCS
  # implementations `Module`s
  #
  # @author Sebastian Staudt
  module VCS

    # This module provided class methods for VCS implementation `Module`s that
    # implement smart auto-loading of dependencies and classes.
    #
    # @author Sebastian Staudt
    module ClassMethods

      # Returns the adapter implementation `Module` for a given symbolic
      # adapter name
      #
      # @param [Symbol] name The symbolic name of the adapter
      # @return [Module] The adapter for the given name
      def adapter(name)
        adapters[name.to_sym]
      end

      # Returns the adapters registered for this VCS
      #
      # @return [Hash<Symbol, Module>] The registered VCS adapters
      def adapters
        class_variable_get :@@adapters
      end
      
      # Sets the symbolic name for this VCS and registers it
      #
      # @param [Symbol] name The symbolic name for this VCS
      def as(name)
        Metior.register name, self
        class_variable_set :@@id, name
      end

      # Sets or returns the default adapter for this VCS
      #
      # @param [Symbol] The 
      # @return [Module] This VCS's default adapter
      def default_adapter(name = nil)
        if name.nil?
          Metior.adapter(class_variable_get :@@default_adapter)
        else
          class_variable_set :@@default_adapter, name
        end
      end
      
      # Returns the symbolic name of this VCS
      #
      # @return [Symbol] The symbolic name of this VCS
      def id
        class_variable_get :@@id
      end

      # Registers an adapter `Module` to be used for this VCS
      #
      # @param [Symbol] name The symbolic name to use for the adapter
      # @param [Module] adapter The adapter to register
      def register_adapter(name, adapter)
        adapters[name] = adapter
      end

    end

    # Including `VCS` will prepare a `Module` for use as a supported VCS type
    # in Metior
    #
    # @param [Module] mod The `Module` that provides a Metior implementation
    #        for a specific VCS
    # @raise [RuntimeError] if the VCS `Module` does not have the `NAME`
    #        constant defined prior to including `Metior::VCS`
    # @see Metior.vcs_types
    def self.included(mod)
      mod.extend ClassMethods
      mod.send :class_variable_set, :@@adapters, {}
    end

    # Returns the VCS module that is included by this object
    #
    # @return [Metior::VCS] The VCS implementation module of this object
    # @see Metior.vcs_types
    def vcs
      singleton_class.included_modules.find { |mod| mod.include? VCS }
    end

  end

end

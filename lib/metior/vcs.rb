# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior'

module Metior

  # This hash will be dynamically filled with all available VCS types and the
  # corresponding implementation modules
  @@vcs_types = {}

  # Returns the VCS implementation +Module+ for a given symbolic VCS name
  #
  # @param [Symbol] type The symbolic type name of the VCS
  # @return [VCS] The VCS for the given name
  def self.vcs(type)
    type = type.to_sym
    unless @@vcs_types.key? type
      raise 'No VCS registered for :%s' % type
    end
    @@vcs_types[type].init
  end

  # Returns a Hash with all available VCS types as keys and the implementation
  # modules as values
  #
  # @return [Hash<Symbol, VCS>] All available VCS implementations and their
  #         corresponding names
  def self.vcs_types
    @@vcs_types
  end

  # This module provides functionality to automatically register new VCS
  # implementations +Module+s
  #
  # @author Sebastian Staudt
  module VCS

    # This module provided class methods for VCS implementation +Module+s that
    # implement smart auto-loading of dependencies and classes.
    module ClassMethods

      # Missing constants may indicate
      #
      # Trying to access either the +Actor+, +Commit+ or +Repository+ class
      # in a VCS +Module+ will trigger auto-loading first.
      #
      # @param [Symbol] The symbolic name of the missing constant
      # @see #init
      def const_missing(const)
        init if [:Actor, :Commit, :Repository].include?(const)
        super unless const_defined? const
        const_get const
      end

      # This initializes the VCS's implementation +Module+
      #
      # First the corresponding Bundler group is loaded so all dependencies are
      # met. Afterwards the +Actor+, +Commit+ and +Repository+ classes are
      # required.
      #
      # @see Bundler.setup
      def init
        Bundler.setup self::NAME

        path = self::NAME.to_s
        require "metior/#{path}/actor"
        require "metior/#{path}/commit"
        require "metior/#{path}/repository"

        self
      end

      # Checks if a specific feature is supported by the VCS (or its
      # implementation)
      #
      # @return [true, false] +true+ if the feature is supported
      # @see VCS#supports?
      def supports?(feature)
        self.send(:class_variable_get, :@@features)[feature] == true
      end

    end

    # Including +VCS+ will make a +Module+ available as a supported VCS type in
    # Metior
    #
    # @example This will automatically register +ExoticVCS+ as +:exotic+
    #   module ExoticVCS
    #
    #     NAME = :exotic
    #
    #     include Metior::VCS
    #
    #   end
    #
    # @param [Module] mod The +Module+ that provides a Metior implementation
    #        for a specific VCS
    # @see Metior.vcs_types
    def self.included(mod)
      mod.extend ClassMethods
      mod.send :class_variable_set, :@@features, {
        :line_stats => true
      }

      Metior.vcs_types[mod::NAME.to_sym] = mod
    end

    # Checks if a specific feature is supported by the VCS (or its
    # implementation)
    #
    # @return [true, false] +true+ if the feature is supported
    # @see ClassMethods#supports?
    def supports?(feature)
      self.class.included_modules.first.supports? feature
    end

  end

end

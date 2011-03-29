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
    @@vcs_types[type]
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
    # @see Metior#vcs_types
    def self.included(mod)
      Metior.vcs_types[mod::NAME.to_sym] = mod
      @@vcs = mod
    end

    # This is a helper method to easily refer to the currently used VCS
    # implementation +Module+ from outside its scope, e.g. inside of
    # +Metior::Repository+.
    #
    # @return [VCS] The current VCS implementation +Module+
    def vcs
      @@vcs
    end

  end

end

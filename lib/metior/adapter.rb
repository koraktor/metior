# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

# @author Sebastian Staudt
module Metior::Adapter

  # @author Sebastian Staudt
  module ClassMethods

    # Missing constants may indicate that the adapter is not yet initialized
    #
    # Trying to access either the `Actor`, `Commit` or `Repository` class
    # in a adapter `Module` will trigger auto-loading first.
    #
    # @param [Symbol] const The symbolic name of the missing constant
    # @see #init
    def const_missing(const)
      init if [:Actor, :Commit, :Repository].include?(const)
      super unless const_defined? const
      const_get const
    end

    # This initializes the adapter `Module`
    #
    # This requires the `Actor`, `Commit` and `Repository` classes for that
    # adapter implementation.
    def init
      path = id.to_s
      autoload :Actor,      "metior/adapter/#{path}/actor"
      autoload :Commit,     "metior/adapter/#{path}/commit"
      autoload :Repository, "metior/adapter/#{path}/repository"

      self
    end

    # Marks one or more features as not supported by the adapter
    #
    # @example Mark this adapter as not supporting file stats
    #     not_supporting :file_stats
    # @param [Array<Symbol>] features The features that are not supported
    # @see #supports?
    def not_supporting(*features)
      features.each do |feature|
        class_variable_get(:@@features)[feature] = false
      end
    end

    # Registers this adapter with a VCS
    #
    # @param [Symbol] vcs_name The name of the VCS to register this adapter
    #        with
    def register_for(vcs)
      vcs = Metior.vcs vcs
      vcs.register_adapter id, self
      class_variable_set :@@vcs, vcs
    end

    # Checks if a specific feature is supported by the adapter
    #
    # @param [Symbol] feature The feature to check
    # @return [true, false] `true` if the feature is supported
    # @see #not_supported
    # @see VCS#supports?
    def supports?(feature)
      class_variable_get(:@@features)[feature] == true
    end

    # Returns the VCS of the adapter
    #
    # @return [VCS] The VCS of the adapter
    def vcs
      class_variable_get :@@vcs
    end

  end

  # Including `Adapter` will make a `Module` available as an adapter for use
  # in Metior
  #
  # @param [Module] mod The `Module` that provides an adapter for a specific
  #        VCS
  def self.included(mod)
    mod.extend ClassMethods
    mod.extend Metior::Registerable
    mod.send :class_variable_set, :@@features, {
      :file_stats => true,
      :line_stats => true
    }
  end

  # Returns the adapter module that is included by this object
  #
  # @return [Module] The adapter implementation module of this object
  # @see Metior.adapter_types
  def adapter
    singleton_class.included_modules.find { |mod| mod.include? Metior::Adapter }
  end

  # Checks if a specific feature is supported by the adapter and raises an
  # error if the feature is not available
  #
  # @raise [UnsupportedError] if the feature is not supported by the adapter
  # @see #supports?
  def support!(feature)
    raise Metior::UnsupportedError.new(adapter) unless supports? feature
  end

  # Checks if a specific feature is supported by the adapter
  #
  # @param [Symbol] feature The feature to check
  # @return [true, false] `true` if the feature is supported
  # @see #not_supported
  # @see VCS#supports?
  def supports?(feature)
    adapter.supports? feature
  end

  # Returns the VCS of the adapter
  #
  # @return [VCS] The VCS of the adapter
  def vcs
    adapter.vcs
  end

end

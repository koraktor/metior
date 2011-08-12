# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'metior/report/view_helper'

class Metior::Report

  # This class is an extended Mustache view
  #
  # A view represents a whole page or a section of a page that displays
  # information about a repository. It is always attached to a specific report
  # and can access the information of the report and the repository.
  #
  # @author Sebastian Staudt
  class View < Mustache

    include ViewHelper

    # This will initialize new view classes
    #
    # @param [Class] subclass The inheriting view class
    def self.inherited(subclass)
      subclass.send :class_variable_set, :@@required_features, []
    end

    # Specifies one or more VCS features that are required to generate this
    # view
    #
    # @example
    #   class LineStatsView < View
    #
    #     requires :line_stats
    #
    #     ...
    #
    #   end
    # @param [Symbol, ...] features One ore more features that are required for
    #        this view
    def self.requires(*features)
      required_features = class_variable_get :@@required_features
      required_features += features
      class_variable_set :@@required_features, required_features
    end

    # Initializes this view with the given report
    #
    # @param [Report] report The report this view belongs to
    def initialize(report)
      @report = report
    end

    # This will try to render a view as a partial of the current view or call a
    # method of the repository
    #
    # The partial view will either be aquired from the current view namespace,
    # i.e. the report this view belongs to, or from the default report.
    #
    # @param [Symbol] name The name of the view to render or the repository
    #        method to call
    # @param [Object, ...] args The arguments to pass to the method
    # @param [Proc] block The block to pass to the method
    # @see Default
    # @see http://rubydoc.info/gems/mustache/Mustache#view_class-class_method
    #      Mustache.view_class
    def method_missing(name, *args, &block)
      view_class = Mustache.view_class name
      return view_class.new(@report).render if view_class != Mustache

      repository.send name, *args, &block
    end

    # This checks if all required VCS features of this view are available for
    # this report's repository
    #
    # @param [Object, ...] args The arguments expected by {Mustache#render}
    # @see .requires
    # @see http://rubydoc.info/gems/mustache/Mustache#render-instance_method
    #      Mustache#render
    def render(*args)
      features = self.class.send :class_variable_get, :@@required_features
      super if features.all? { |feature| repository.supports? feature }
    end

    # Returns the repository that is analyzed by the report this view belongs
    # to
    #
    # @return [Repository] The repository belonging to this view's report
    def repository
      @report.repository
    end

    # Returns whether the given name refers a partial view that can be rendered
    # or method that can be called
    #
    # This checks whether this view has a method with the given name, or if
    # another view with this name exists, or if the repository has a method
    # with this name.
    #
    # @param [Symbol] name The name of the partial or method
    # @return [Boolean] `true` if the given name refers a partial or method
    # @see http://rubydoc.info/gems/mustache/Mustache#view_class-class_method
    #      Mustache.view_class
    def respond_to?(name)
      methods.include?(name.to_s) ||
      Mustache.view_class(name) != Mustache ||
      repository.respond_to?(name)
    end

    # Returns the name of the VCS the analyzed repository is using
    #
    # @return [Symbol] The name of the current VCS
    def vcs_name
      repository.vcs::NAME
    end

  end

end

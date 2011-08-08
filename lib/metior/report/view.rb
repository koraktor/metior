# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

class Metior::Report

  # @author Sebastian Staudt
  class View < Mustache

    def self.inherited(subclass)
      subclass.send :class_variable_set, :@@required_features, []
    end

    def self.requires(*features)
      required_features = class_variable_get :@@required_features
      required_features += features
      class_variable_set :@@required_features, required_features
    end

    def initialize(report)
      @count  = 0
      @report = report
    end

    def even_odd
      ((@count += 1) % 2 == 0) ? 'even' : 'odd'
    end

    def method_missing(name, *args, &block)
      view_class = Mustache.view_class name
      return view_class.new(@report).render if view_class != Mustache

      unless Mustache.view_namespace == Metior::Report::Default
        old_namespace = Mustache.view_namespace
        Mustache.view_namespace = Metior::Report::Default
        view_class = Mustache.view_class name
        if view_class != Mustache
          Mustache.view_namespace = old_namespace
          return view_class.new(@report).render
        end
      end

      repository.send name, *args, &block
    end

    def render(*args)
      required_features = self.class.send :class_variable_get, :@@required_features
      return unless required_features.all? { |f| repository.supports? f }
      super
    end

    def repository
      @report.repository
    end

    def reset_even_odd
      @count = 0
    end

    def respond_to?(name)
      methods.include?(name.to_s) ||
      Mustache.view_class(name) != Mustache ||
      repository.respond_to?(name)
    end

    def vcs_name
      repository.vcs::NAME
    end

  end

end

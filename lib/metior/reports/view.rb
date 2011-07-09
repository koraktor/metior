# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior

  module Reports

    # @author Sebastian Staudt
    class View < Mustache

      def initialize(report, repository)
        @report     = report
        @repository = repository
      end

      def method_missing(name, *args, &block)
        view_class = Mustache.view_class name
        return view_class.new(@report, @repository).render if view_class != Mustache

        Mustache.view_namespace = Metior::Reports::Default
        view_class = Mustache.view_class name
        return view_class.new(@report, @repository).render if view_class != Mustache

        @repository.send name, *args, &block
      end

      def respond_to?(name)
        methods.include?(name.to_s) ||
        Mustache.view_class(name) != Mustache ||
        @repository.respond_to?(name)
      end

      def vcs_name
        @repository.vcs::NAME
      end

    end

  end

end

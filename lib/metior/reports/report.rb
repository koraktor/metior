# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'fileutils'
require 'hashie/mash'
require 'mustache'

require 'metior/reports/view'

module Metior

  module Reports

    # @author Sebastian Staudt
    class Report

      REPORTS_PATH = File.expand_path File.join File.dirname(__FILE__), '..', '..', '..', 'reports'

      attr_reader :repository

      def self.name
        class_variable_get(:@@name).to_s
      end

      def self.path
        File.join REPORTS_PATH, name
      end

      def self.template_path
        File.join path, 'templates'
      end

      def self.view_path
        File.join path, 'views'
      end

      def self.views
        class_variable_get :@@views
      end

      def initialize(repository)
        @repository = repository
      end

      def generate(target_dir)
        target_dir = File.expand_path target_dir
        copy_assets(target_dir)

        Mustache.template_path  = self.class.template_path
        Mustache.view_path      = self.class.view_path
        Mustache.view_namespace = self.class

        self.class.views.each do |view_name|
          output = Mustache.view_class(view_name).new(self).render
          output_file = File.open File.join(target_dir, view_name.to_s.downcase + '.html'), 'w'
          output_file.write output
          output_file.close
        end
      end

      def path
        self.class.path
      end

      def template_path
        self.class.template_path
      end

      def view_path
        self.class.view_path
      end

      private

      def copy_assets(target_dir)
        FileUtils.mkdir_p target_dir

        %w{images javascripts stylesheets}.map do |type|
          File.join(path, type)
        end.each do |src|
          next unless File.directory? src
          FileUtils.cp_r src, target_dir
        end
      end

    end

  end

end

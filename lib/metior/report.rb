# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'fileutils'
require 'mustache'

require 'metior/report/view'

module Metior

  # @author Sebastian Staudt
  class Report

    REPORTS_PATH = File.expand_path File.join File.dirname(__FILE__), '..', '..', 'reports'

    attr_reader :range

    attr_reader :repository

    def self.create(name, repository, range = repository.vcs::DEFAULT_BRANCH)
      require File.join(REPORTS_PATH, name.to_s)
      name = name.to_s.split('_').map { |n| n.capitalize }.join('')
      const_get(name.to_sym).new(repository, range)
    end

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

    def initialize(repository, range = repository.vcs::DEFAULT_BRANCH)
      @range      = range
      @repository = repository
    end

    def generate(target_dir)
      target_dir = File.expand_path target_dir
      copy_assets(target_dir)

      Mustache.template_path  = self.class.template_path
      Mustache.view_path      = self.class.view_path
      Mustache.view_namespace = self.class

      self.class.views.each do |view_name|
        file_name = File.join target_dir, view_name.to_s.downcase + '.html'
        begin
          output_file = File.open file_name, 'w'
          output_file.write Mustache.view_class(view_name).new(self).render
        ensure
          output_file.close
        end
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

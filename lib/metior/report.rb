# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'fileutils'
require 'mustache'

require 'metior/report/view'

module Metior

  # This class represents a report
  #
  # A report is a collection of Mustache views that have access to the
  # repository attached to this report.
  #
  # @author Sebastian Staudt
  # @see View
  class Report

    # The path where the reports bundled with Metior live
    REPORTS_PATH = File.expand_path File.join File.dirname(__FILE__), '..', '..', 'reports'

    # Returns the range of commits that should be analyzed by this report
    #
    # @return [String, Range] The range of commits covered by this report
    attr_reader :range

    # Returns the repository that should be analyzed by this report
    #
    # @return [Repository] The repository attached to this report
    attr_reader :repository

    # Create a new report instance for the given report name, repository and
    # commit range
    #
    # @param [String, Symbol] name The name of the report to load and
    #        initialize
    # @param [Repository] repository The repository to analyze
    # @param [String, Range] range The commit range to analyze
    def self.create(name, repository, range = repository.vcs::DEFAULT_BRANCH)
      require File.join(REPORTS_PATH, name.to_s)
      name = name.to_s.split('_').map { |n| n.capitalize }.join('')
      const_get(name.to_sym).new(repository, range)
    end

    # Returns the name of this report
    #
    # @return [String] The name of this report
    def self.name
      class_variable_get(:@@name).to_s
    end

    # Returns the file system path this report resides in
    #
    # @return [String] The path of this report
    def self.path
      File.join REPORTS_PATH, name
    end

    # Returns the file system path this report's templates reside in
    #
    # @return [String] The path of this report's templates
    def self.template_path
      File.join path, 'templates'
    end

    # Returns the file system path this report's views reside in
    #
    # @return [String] The path of this report's views
    def self.view_path
      File.join path, 'views'
    end

    # Returns the symbolic names of the main views this report consists of
    #
    # @reeturn [Array<Symbol>] This report's views
    def self.views
      class_variable_get :@@views
    end

    # Creates a new report for the given repository and commit range
    #
    # @param [Repository] repository The repository to analyze
    # @param [String, Range] range The commit range to analyze
    def initialize(repository, range = repository.vcs::DEFAULT_BRANCH)
      @range      = range
      @repository = repository
    end

    # Generates this report's output into the given target directory
    #
    # This will generate individual HTML files for the main views of the
    # report.
    #
    # @param [String] target_dir The target directory of the report
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

    # Returns the file system path this report resides in
    #
    # @return [String] The path of this report
    def path
      self.class.path
    end

    # Returns the file system path this report's templates reside in
    #
    # @return [String] The path of this report's templates
    def template_path
      self.class.template_path
    end

    # Returns the file system path this report's views reside in
    #
    # @return [String] The path of this report's views
    def view_path
      self.class.view_path
    end

    private

    # Copies the assets coming with this report to the given target directory
    #
    # This will copy the contents of the `images`, `javascript` and
    # `stylesheets` directories inside the report's path into the target
    # directory.
    #
    # @param [String] target_dir The target directory of the report
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

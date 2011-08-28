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

    # Returns the commits analyzed by this report
    #
    # @return [CommitCollection] The commits analyzed by this report
    attr_reader :commits

    # Returns the range of commits that should be analyzed by this report
    #
    # @return [String, Range] The range of commits covered by this report
    attr_reader :range

    # Returns the repository that should be analyzed by this report
    #
    # @return [Repository] The repository attached to this report
    attr_reader :repository

    # Returns the paths of the assets that need to be included in the report
    #
    # By default, a report uses the directories `images`, `javascripts` and
    # `stylesheets` as asset sources.
    #
    # @return [Array<String>] The paths of the assets to include
    def self.assets
      if class_variable_defined? :@@assets
        class_variable_get :@@assets
      else
        %w{images javascripts stylesheets}
      end
    end

    # Create a new report instance for the given report name, repository and
    # commit range
    #
    # @param [String, Symbol] name The name of the report to load and
    #        initialize
    # @param [Repository] repository The repository to analyze
    # @param [String, Range] range The commit range to analyze
    # @return [Report] The requested report
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
      @commits    = repository.commits range

      init
    end

    # Generates this report's output into the given target directory
    #
    # This will generate individual HTML files for the main views of the
    # report.
    #
    # @param [String] target_dir The target directory of the report
    # @param [Boolean] with_assets If `false` the report's assets will not be
    #        copied to the target directory
    def generate(target_dir, with_assets = true)
      target_dir = File.expand_path target_dir
      copy_assets target_dir if with_assets

      render.each do |view_name, output|
        file_name = File.join target_dir, view_name.to_s.downcase + '.html'
        begin
          output_file = File.open file_name, 'wb'
          output_file.write output
        ensure
          output_file.close
        end
      end
    end

    # Initializes a new report instance
    #
    # This can be used to gather initial data, e.g. used by multiple views.
    #
    # @abstract Override this method to customize the initial setup of a report
    def init
    end

    # Renders the views of this report and returns them in a hash
    #
    # @return [Hash<Symbol, String>] The names of the views and the
    #         corresponding rendered content
    def render
      Mustache.template_path  = self.class.template_path
      Mustache.view_path      = self.class.view_path
      Mustache.view_namespace = self.class

      result = {}
      self.class.views.each do |view_name|
        result[view_name] = Mustache.view_class(view_name).new(self).render
      end
      result
    end

    private

    # Copies the assets coming with this report to the given target directory
    #
    # This will copy the files and directories that have been specified for the
    # report from the report's path into the target directory.
    #
    # @param [String] target_dir The target directory of the report
    # @see .assets
    def copy_assets(target_dir)
      FileUtils.mkdir_p target_dir

      self.class.assets.map do |asset|
        asset_dir = File.join target_dir, File.dirname(asset)
        FileUtils.mkdir_p asset_dir unless File.exists? asset_dir
        FileUtils.cp_r File.join(self.class.path, asset), asset_dir
      end
    end

  end

end

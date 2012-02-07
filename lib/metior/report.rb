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

    # This holds all available reports, i.e. their names and the corresponding
    # class
    @@reports = {}

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

    # Sets or returns the paths of the assets that need to be included in the
    # report
    #
    # @param [Array<String>] assets The paths of the assets for this report
    # @return [Array<String>] The paths of the assets to include
    def self.assets(assets = nil)
      if assets.nil?
        if class_variable_defined? :@@assets
          class_variable_get :@@assets
        else
          self == Report ? [] : superclass.assets
        end
      else
        class_variable_set :@@assets, assets
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
    def self.create(name, repository, range = repository.current_branch)
      @@reports[name.to_s].new(repository, range)
    end

    # Automatically registers a new report subclass as an available report type
    #
    # This will also set the path of the new report class, so it can find its
    # views, templates and assets.
    #
    # @param [Class] subclass A report subclass
    def self.inherited(subclass)
      @@reports[subclass.name] = subclass
      base_path = File.dirname caller.first.split(':').first
      subclass.send :class_variable_set, :@@base_path, base_path
    end

    # Sets or returns the name of this report
    #
    # @param [String] name The name for this report
    # @return [String] The name of this report
    def self.name(name = nil)
      if name.nil?
        if class_variable_defined? :@@name
          class_variable_get(:@@views).to_s
        else
          self.to_s.split('::').last.downcase
        end
      else
        class_variable_set :@@name, name
      end
    end

    # Returns the file system path this report resides in
    #
    # @return [String] The path of this report
    def self.path
      File.join class_variable_get(:@@base_path), name
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

    # Sets or returns the symbolic names of the main views this report consists
    # of
    #
    # @param [Array<Symbol>] views The views for this report
    # @return [Array<Symbol>] This report's views
    def self.views(views = nil)
      if views.nil?
        if class_variable_defined? :@@views
          class_variable_get :@@views
        else
          self == Report ? [] : superclass.views
        end
      else
        class_variable_set :@@views, views
      end
    end

    # Creates a new report for the given repository and commit range
    #
    # @param [Repository] repository The repository to analyze
    # @param [String, Range] range The commit range to analyze
    def initialize(repository, range = repository.current_branch)
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

    # Renders the views of this report (or the its ancestors) and returns them
    # in a hash
    #
    # @return [Hash<Symbol, String>] The names of the views and the
    #         corresponding rendered content
    def render
      Mustache.view_namespace = self.class

      result = {}
      self.class.views.each do |view_name|
        template = File.join 'templates', "#{view_name}.mustache"
        template_path = self.class.find template

        view = File.join 'views', "#{view_name}.rb"
        view_path = self.class.find view

        Mustache.template_path = File.dirname template_path
        Mustache.view_path     = File.dirname view_path
        mustache = Mustache.view_class(view_name).new(self)
        mustache.template_name = view_name
        result[view_name] = mustache.render
      end
      result
    end

    require File.join(REPORTS_PATH, 'default')

    private

    # Find a file inside this report or one of its ancestors
    #
    # @param [String] file The name of the file to find
    # @param [Report] report The report this file was initially requested for
    # @return [String, nil] The absolute path of the file or `nil` if it
    #         doesn't exist in this reports hierarchy
    def self.find(file, report = self)
      current_path = File.join self.path, file
      if File.exist? current_path
        current_path
      else
        if superclass == Report
          raise FileNotFoundError.new file, report
        end
        superclass.find file, report
      end
    end

    # Copies the assets coming with this report to the given target directory
    #
    # This will copy the files and directories that have been specified for the
    # report from the report's path (or the report's ancestors) into the target
    # directory.
    #
    # @param [String] target_dir The target directory of the report
    # @see .assets
    def copy_assets(target_dir)
      FileUtils.mkdir_p target_dir

      self.class.assets.map do |asset|
        asset_path = self.class.find asset
        asset_dir = File.join target_dir, File.dirname(asset)
        FileUtils.mkdir_p asset_dir unless File.exists? asset_dir
        FileUtils.cp_r asset_path, asset_dir
      end
    end

  end

end

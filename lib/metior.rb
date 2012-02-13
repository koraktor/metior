# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2012, Sebastian Staudt

require 'core_ext/object'
require 'metior/errors'
require 'metior/version'

# Metior is a source code history analyzer that provides various statistics
# about a source code repository and its change over time.
#
# @author Sebastian Staudt
module Metior

  autoload :Actor,              'metior/actor'
  autoload :Adapter,            'metior/adapter'
  autoload :ActorCollection,    'metior/collections/actor_collection'
  autoload :AutoIncludeAdapter, 'metior/auto_include_adapter'
  autoload :Collection,         'metior/collections/collection'
  autoload :Commit,             'metior/commit'
  autoload :CommitCollection,   'metior/collections/commit_collection'
  autoload :Registerable,       'metior/registerable'
  autoload :Report,             'metior/report'
  autoload :Repository,         'metior/repository'
  autoload :VCS,                'metior/vcs'

  # This holds all available reports, i.e. their names and the corresponding
  # class
  @@reports = {}

  # This hash will be dynamically filled with all available VCS adapters and
  # the corresponding modules
  @@vcs_adapters = {}

  # This hash will be dynamically filled with all available VCS types and the
  # corresponding modules
  @@vcs_types = {}

  # Creates a new repository for the given VCS or adapter name and repository
  # path
  #
  # @param [Symbol] name The name of the repository's VCS or the adapter to use
  # @param [Array<Object>] options The options to use for creating the new
  #        repository, e.g. a file system path
  # @return [Repository] A VCS specific `Repository` instance
  def self.repository(name, *options)
    begin
      adapter = find_adapter name
    rescue UnknownAdapterError
      adapter = find_vcs(name).default_adapter
    end
    adapter::Repository.new *options
  end

  # Generates a report for the given repository
  #
  # @param [Symbol] type The type of the repository, e.g. `:git`
  # @param [Array<Object>] options The options to use for creating the new
  #        repository, e.g. a file system path
  # @param [String] target_dir The target directory to save the report to
  # @param [String, Range] range The commit range to analyze for the report
  # @param [String] report The name of the report template to use
  def self.report(type, repo_options, target_dir, range = nil, report = 'default')
    repo = repository type, *repo_options
    range ||= repo.current_branch
    Report.create(report, repo, range).generate target_dir
  end

  # Calculates simplistic stats for the given repository and branch
  #
  # @param [Symbol] type The type of the repository, e.g. `:git`
  # @param [Object, Array<Object>] repo_options The options to supply to the
  #        repository
  # @param [String, Range] range The range of commits for which the commits
  #        should be loaded. This may be given as a string
  #        (`'master..development'`), a range (`'master'..'development'`) or as
  #        a single ref (`'master'`). A single ref name means all commits
  #        reachable from that ref.
  # @return [Hash<Symbol, Object>] The calculated stats for the given
  #         repository and branch
  def self.simple_stats(type, repo_options, range = nil)
    repo  = repository type, *repo_options
    range ||= repo.current_branch

    commits = repo.commits(range)
    {
      :commit_count     => commits.size,
      :top_contributors => repo.top_contributors(range, 5)
    }.merge commits.activity
  end

  # Returns the adapter `Module` for a given symbolic adapter name
  #
  # @param [Symbol] name The symbolic name of the adapter
  # @return [Module] The adapter for the given name
  def self.find_adapter(name)
    name = name.to_sym
    raise UnknownAdapterError.new(name) unless @@vcs_adapters.key? name
    @@vcs_adapters[name]
  end

  # Find the base class of the report with the given name
  #
  # @param [Symbol] The symbolic name of the report
  # @return [Class] The report for the given name
  def self.find_report(name)
    name = name.to_sym
    raise UnknownReportError.new(name) unless @@reports.key? name
    @@reports[name]
  end

  # Registers a VCS or adapter `Module` using the given symbolic name
  #
  # @param [Symbol] name The symbolic name to register the `Module` as
  # @param [Module] mod The component to register
  def self.register(name, mod)
    if mod.include? VCS
      @@vcs_types[name] = mod
    elsif mod.include? Adapter
      @@vcs_adapters[name] = mod
    elsif mod.include? Report
      @@reports[name] = mod
    end
  end

  # Returns the VCS `Module` for a given symbolic VCS name
  #
  # @param [Symbol] name The symbolic name of the VCS
  # @return [Module] The VCS for the given name
  def self.find_vcs(name)
    name = name.to_sym
    raise UnknownVCSError.new(name) unless @@vcs_types.key? name
    @@vcs_types[name]
  end

end

require 'metior/vcs/git'

# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior::Reports

  # @author Sebastian Staudt
  class Default::RepositoryInformation < View

    def initialize(report)
      super

      @activity = repository.commits.activity
    end

    def commit_count
      repository.commits.size
    end

    def commits_per_active_day
      (@activity[:commits_per_active_day] * 100).round / 100.0
    end

    def initial_commit_date
      @activity[:first_commit_date]
    end

    def last_commit_date
      @activity[:last_commit_date]
    end

    def most_active_day
      @activity[:most_active_day].strftime '%m/%d/%Y'
    end

    def repository_path
      repository.path
    end

  end

end

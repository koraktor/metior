# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

class Metior::Report::Default

  # @author Sebastian Staudt
  class RepositoryInformation < View

    def initialize(report)
      super

      @activity = repository.commits(report.range).activity
    end

    def commit_count
      repository.commits(@report.range).size
    end

    def commits_per_active_day
      (@activity[:commits_per_active_day] * 100).round / 100.0 rescue 0
    end

    def initial_commit_date
      @activity[:first_commit_date]
    end

    def last_commit_date
      @activity[:last_commit_date]
    end

    def most_active_day
      @activity[:most_active_day].strftime '%m/%d/%Y' rescue ''
    end

    def range
      @report.range
    end

    def repository_path
      repository.path
    end

  end

end

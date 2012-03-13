# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2012, Sebastian Staudt

require 'date'

require 'core_ext/date'
require 'multi_json'

class Metior::Report::Default

  # @author Sebastian Staudt
  class Impact < View

    def data
      commits = @report.commits

      return '{}' if commits.empty?

      authors = commits.authors
      author_indices = {}
      authors.each_with_index { |author, index| author_indices[author.id] = index }

      first = commits.last.committed_date.send :to_date
      last = commits.first.committed_date.send :to_date
      first_monday = first - (first.wday - 1)

      impact_data = []
      first_monday.step(last, 7) do |week|
        next_week = (week + 7).to_time
        week_commits = commits.before next_week
        commits = commits.after next_week

        week_data = { :d => week.to_time.to_i }
        week_data[:i] = []
        week_commits.authors.each do |author|
          week_data[:i] << [ author_indices[author.id], week_commits.by(author.id).modifications ]
        end
        impact_data << week_data
      end

      author_data = {}
      authors.each do |author|
        author_data[author_indices[author.id]] = {
          :n => author.name,
          :c => author.commits.size,
          :a => author.commits.additions,
          :d => author.commits.deletions
        }
      end

      MultiJson.encode({ :authors => author_data, :buckets => impact_data })
    end

    def meta_now
      now.strftime('%FT%H:%M:%S%z').insert(-3, ':')
    end

    def now
      Time.now
    end

    def repo_name
      repository.name.empty? ? repository.path : repository.name
    end

    def title
      "Impact graph for #{repo_name}"
    end

    def version
      Metior::VERSION
    end

  end

end

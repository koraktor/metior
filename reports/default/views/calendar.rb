# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

require 'date'

class Metior::Report::Default

  # @author Sebastian Staudt
  class Calendar < View

    def data
      data = {}
      @report.commits.each do |commit|
        date = commit.committed_date.send :to_date
        if data.key? date
          data[date][:commits] += 1
          data[date][:additions] += commit.additions
          data[date][:deletions] += commit.deletions
        else
          data[date] = {
            :commits => 1,
            :additions => commit.additions,
            :deletions => commit.deletions
          }
        end
      end

      js_data = []

      unless @report.commits.empty?
        first = @report.commits.last.committed_date.send :to_date
        last = @report.commits.first.committed_date.send :to_date
        first.upto last do |current|
          next unless data.key? current
          js_data << ("'#{current.strftime '%m/%d/%Y'}': {" <<
            "'additions': #{data[current][:additions]}," <<
            "'commits': #{data[current][:commits]}," <<
            "'deletions': #{data[current][:deletions]} }")
        end
      end

      "{ #{js_data.join(',')} }"
    end

    def first_year
      return nil if @report.commits.empty?
      @report.commits.last.committed_date.year
    end

    def last_year
      return nil if @report.commits.empty?
      @report.commits.first.committed_date.year
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
      "Calendar for #{repo_name}"
    end

    def version
      Metior::VERSION
    end

  end

end

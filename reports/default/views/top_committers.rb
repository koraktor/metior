# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

class Metior::Report::Default

  # @author Sebastian Staudt
  class TopCommitters < View

    def committers
      repository.authors(@report.range).top(5).values
    end

    def commit_count
      "#{self[:authored_commits].size} commits"
    end

  end

end

# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior::Reports

  # @author Sebastian Staudt
  class Default::TopCommitters < View

    def committers
      repository.authors.top(5).values
    end

    def commit_count
      "#{self[:authored_commits].size} commits"
    end

  end

end

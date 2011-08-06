# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior::Reports

  # @author Sebastian Staudt
  class Default::MostSignificantCommits < View

    requires :line_stats

    def commits
      repository.commits.most_significant(5).values
    end

  end

end

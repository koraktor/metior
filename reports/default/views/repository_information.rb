# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior::Reports

  # @author Sebastian Staudt
  class Default::RepositoryInformation < View

    def commit_count
      @repository.commits.size
    end

    def initial_commit_date
      @repository.commits.last.committed_date
    end

    def last_commit_date
      @repository.commits.first.committed_date
    end

    def repository_path
      @repository.path
    end

  end

end

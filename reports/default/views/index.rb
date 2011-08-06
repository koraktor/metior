# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

module Metior::Reports

  # @author Sebastian Staudt
  class Default::Index < View

    def repo_name
      repository.name.empty? ? repository.path : repository.name
    end

    def title
      "Stats for #{repo_name}"
    end

    def version
      Metior::VERSION
    end

  end

end

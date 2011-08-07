# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

class Metior::Report::Default

  # @author Sebastian Staudt
  class Index < View

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
      "Stats for #{repo_name}"
    end

    def version
      Metior::VERSION
    end

  end

end

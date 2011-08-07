# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011, Sebastian Staudt

class Metior::Report::Default

  # @author Sebastian Staudt
  class MostSignificantAuthors < View

    requires :line_stats

    def authors
      repository.authors.most_significant(5).values
    end

  end

end

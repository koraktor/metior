Metior
======

Metior is a source code history analyzer API that provides various statistics
about a source code repository and its change over time.

Currently Metior provides support for Git and GitHub repositories.

If you're interested in Metior, feel free to join the discussion on Convore in
[Metior's group](https://convore.com/metior).

## Reports

The most straightforward use of Metior is probably generating an out-of-the-box
report that analyzes a repository and gives a user-friendly output of the
gathered data.

    Metior.report :git, '~/open-source/metior', './reports/metior'
    Metior.report :github, 'koraktor/metior', './reports/metior'

## API Examples

If you want more sophisticated access to the available data, you can use the
low-level API that provides stats for repositories and their individual commits
and actors.

### One-liner for some basic statistics

    Metior.simple_stats :git, '~/open-source/metior'
    Metior.simple_stats :github, 'koraktor/metior'

### Create a repository object for different VCSs

    repo = Metior.repository :git, '~/open-source/metior'
    repo = Metior.repository :github, 'koraktor/metior'

### More fine-grained access to repository statistics

    repo.commits 'development'         # Get all commits in branch development
    repo.file_stats                    # Basic statistics about the files
                                       # contained in a repository
    repo.line_history                  # Quick access to lines added and
                                       # removed in each commit
    repo.significant_authors           # Get up to 3 of the most important
                                       # authors
    repo.significant_commits           # Get up to 3 of the commits changing
                                       # the most lines
    repo.authors('master').top 5       # Get the top 5 authors in master

### Query a collection of commits

    repo.commits.activity
    repo.commits.after '05/29/2010'
    repo.commits.additions
    repo.commits.authors
    repo.commits.before '05/29/2010'
    repo.commits.by 'koraktor'
    repo.commits.changing 'lib/metior.rb'
    repo.commits.deletions
    repo.commits.modifications
    repo.commits.most_significant 10
    repo.commits.with_impact 100

See documentation of {Metior::CommitCollection}

### Query a collection of actors

    repo.authors.authored_commits
    repo.authors.comitted_commits
    repo.authors.most_significant 10
    repo.authors.top 10

See documentation of {Metior::ActorCollection}

## Advanced usage

### Chain collection querys

Querys on a collection of commits or actors can be easily chained to achieve
complex filters on the available data.

    repo.commits.by('koraktor').after('05/29/2010').with_impact 100
    repo.authors.top(10).commits.changing 'lib/metior.rb'

### Specifying commit ranges

Usually, when Metior queries a repository for its commits and authors it will
use the default branch of the VCS, e.g. `master` for Git.

Sometimes it's more useful to not analyze the whole history of a repository's
branch. For example when analyzing the changes from one branch to another, or
from the last released version to the latest code. In that case you will have
to specify a commit range. Specifying a commit range works just like in Git:

    'master..development'
    'deadbeef..HEAD'
    'master'..'development'

Given that your currently checked out branch is `development` and `master`
points to commit `deadbeef`, the above statements are equal. Please also note
the different syntaxes: The first two example are standard strings which
will be parsed by Metior. The other one is a Ruby `Range` object which can be
used by Metior right away.

## Requirements

* Grit — a Ruby API for Git
  * [Git](http://git-scm.com) >= 1.6
* Octokit — a Ruby wrapper for the GitHub API

## Documentation

The documentation of the Ruby API can be seen at [RubyDoc.info][1]. The API
documentation of the current development version is also available [there][5].

## Future plans

* Provide more reports
* Generation of reports in formats other than HTML
* Support for creating graphs
* Console and web application to accompany this API
* More supported VCSs, like Subversion or Mercurial
* Code analysis to show programming languages, effective lines of code, etc.

## Contribute

Metior is a open-source project. Therefore you are free to help improving it.
There are several ways of contributing to Metior's development:

* Build apps using it and spread the word.
* Report problems and request features using the [issue tracker][2].
* Write patches yourself to fix bugs and implement new functionality.
* Create a Metior fork on [GitHub][1] and start hacking. Extra points for using
  feature branches and GitHub's pull requests.

## About the name

The latin word "metior" means "I measure". That's just what Metior does –
measuring source code histories.

## License

This code is free software; you can redistribute it and/or modify it under the
terms of the new BSD License. A copy of this license can be found in the
LICENSE file.

## Credits

* Sebastian Staudt – koraktor(at)gmail.com
* Alex Manelis – amanelis(at)gmail.com
* Michael Klishin – michaelklishin(at)me.com

## See Also

* [API documentation][1]
* [Metior's homepage][2]
* [GitHub project page][3]
* [GitHub issue tracker][4]
* [Continuous Integration at Travis CI][6]

Follow Metior on Twitter [@metiorstats](http://twitter.com/metiorstats).

 [1]: http://rubydoc.info/gems/metior/frames
 [2]: http://koraktor.de/metior
 [3]: http://github.com/koraktor/metior
 [4]: http://github.com/koraktor/metior/issues
 [5]: http://rubydoc.info/github/koraktor/metior/master/frames
 [6]: http://travis-ci.org/koraktor/metior

Metior
======

Metior is a source code history analyzer API that provides various statistics
about a source code repository and its change over time.

Currently Metior provides basic support for Git repositories.

If you're interested in Metior, feel free to join the discussion on Convore in
[Metior's group](https://convore.com/metior).

## Examples

### One-liner for some basic statistics

    Metior.simple_stats :git, '~/open-source/metior'

### More fine-grained access to repository statistics

    repo = Metior::Git::Repository '~/open-source/metior'
    repo.commits 'development'         # Get all commits in development
    repo.line_history                  # Quick access to lines added and
                                       # removed in each commit
    repo.significant_authors           # Get up to 3 of the most important
                                       # authors
    repo.significant_commits, 20       # Get up to 20 of the commits changing
                                       # the most lines
    repo.top_authors 'master', 5       # Get the top 5 authors in master

### Get statistics about a set of commits

    Metior::Commit.activity repo.commits
    Metior::Commit.activity repo.authors[author_id].commits

## Requirements

* Grit — a Ruby API for Git
  * [Git](http://git-scm.com) >= 1.6
* Octokit — a Ruby wrapper for the GitHub API
  * JSON — a JSON parser for Ruby

## Documentation

The documentation of the Ruby API can be seen at [RubyDoc.info][1]. The API
documentation of the current development version is also available [there][5].

## Future plans

* More statistics and analyses
* More supported VCSs, like Subversion or Mercurial
* Support for creating graphs
* Console and web application to accompany this API
* Code analysis to show programming languages, effective lines of code, etc.

## Contribute

Metior is a open-source project. Therefore you are free to help improving it.
There are several ways of contributing to Metior's development:

* Build apps using it and spread the word.
* Report problems and request features using the [issue tracker][2].
* Write patches yourself to fix bugs and implement new functionality.
* Create a Metior fork on [GitHub][1] and start hacking. Extra points for using
  Metior pull requests and feature branches.

## About the name

The latin word "metior" means "I measure". That's just what Metior does –
measuring source code histories.

## License

This code is free software; you can redistribute it and/or modify it under the
terms of the new BSD License. A copy of this license can be found in the
LICENSE file.

## Credits

* Sebastian Staudt – koraktor(at)gmail.com

## See Also

* [API documentation][1]
* [Metior's homepage][2]
* [GitHub project page][3]
* [GitHub issue tracker][4]

Follow Metior on Twitter [@metiorstats](http://twitter.com/metiorstats).

 [1]: http://rubydoc.info/gems/metior/frames
 [2]: http://koraktor.de/metior
 [3]: http://github.com/koraktor/metior
 [4]: http://github.com/koraktor/metior/issues
 [5]: http://rubydoc.info/github/koraktor/metior/master/frames

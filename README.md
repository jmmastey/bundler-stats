Bundler Stats
=============

You remember that time someone yanked their library and the entire Node
universe fell apart? Yeah, me too. And all the thinkpieces that came out just
aftward were right: you should be careful about what you include in your
project.

This project gives you some tools you can use with your existing Gemfile to
determine which gems are including long trees of data, and which you can
potentially remove.

Installation
------------

You don't need to include `bundler-stats` in your Gemfile, just
`gem install bundler-stats`. Unless you wanted to build automation around its
usage, in which case, add it to your Gemfile instead. 


Usage
------------

    > bundle-stats help
      Commands:
        bundle-stats help [COMMAND]  # Describe available commands or one specific command
        bundle-stats show TARGET     # Prints the dependency tree for a single gem in your Gemfile
        bundle-stats stats           # Displays basic stats about the gems in your Gemfile
        bundle-stats version         # Prints the bundler-stats version

Or just run `bundle-stats` anywhere within your ruby project. You can emit JSON
for automatic consumption with `-f json`.


Contributing
------------

Contributions are very welcome. Fork, fix, submit pulls.

Contribution is expected to conform to the [Contributor Covenant](https://github.com/jmmastey/bundler-stats/blob/master/CODE_OF_CONDUCT.md).


Credits
-------

Thanks to the many kind people at [RailsCamp East 2016](http://east.railscamp.com)
for the help, the ideas, and the support.


License
-------

This software is released under the [MIT License](https://github.com/jmmastey/bundler-stats/blob/master/MIT-LICENSE).

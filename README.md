Bundler Stats
=============

You remember that time [someone yanked their
library](http://blog.npmjs.org/post/141577284765/kik-left-pad-and-npm) and the
entire Node universe fell apart? Yeah, me too. And all the
[thinkpieces](http://www.haneycodes.net/npm-left-pad-have-we-forgotten-how-to-program/)
that came out just afterward were right: you should be careful about what
dependencies you include in your project.

This project gives you some tools you can use with an existing Gemfile to
determine which gems are including long trees of their own dependencies, and
which you can potentially remove.

This is an exploratory tool, and I'd be interested to hear what other criteria
would be useful in determining what tools to remove.

Installation
------------

You don't need to include `bundler-stats` in your Gemfile, just
`gem install bundler-stats`. Unless you wanted to build automation around its
usage, in which case, add it to your Gemfile instead.


Usage
------------

    > bundle-stats help
      Commands:
        bundle-stats help [COMMAND]   # Describe available commands or one specific command
        bundle-stats show TARGET      # Prints the dependency tree for a single gem in your Gemfile
        bundle-stats stats            # Displays basic stats about the gems in your Gemfile
        bundle-stats version          # Prints the bundler-stats version
        bundle-stats versions TARGET  # Shows versions requirements for target in other dependencies

The most obvious thing to do is run the command by itself, which should help
identify problem areas:

    > bundle-stats

    +----------------------------|------------|----------------+
    |                       Name | Total Deps | 1st Level Deps |
    +----------------------------|------------|----------------+
    |                rails_admin | 60         | 12             |
    |                      rails | 40         | 12             |
    |              compass-rails | 35         | 3              |
    |                 haml-rails | 29         | 5              |
    |                rspec-rails | 27         | 7              |
    |                 sass-rails | 26         | 5              |
    |                     devise | 26         | 5              |
    |                     scenic | 25         | 2              |
    |               coffee-rails | 25         | 2              |
    |              guard-rubocop | 24         | 2              |
    |                 versionist | 23         | 3              |
    |          factory_bot_rails | 23         | 2              |
    | ... omitted stuff here ...                               |
    +----------------------------|------------|----------------+

          Declared Gems   56
             Total Gems   170
      Unpinned Versions   54
            Github Refs   0

It looks like rails_admin is a huge problem. Use `show` to investigate:

    > bundle-stats show rails_admin
    bundle-stats for rails_admin

    +--------------------------------|----------------------------------------+
    |           Depended Upon By (0) |                                        |
    |                Depends On (60) | builder, coffee-rails                  |
    |                                | font-awesome-rails, haml, jquery-rails |
    |                                | jquery-ui-rails, kaminari, nested_form |
    |                                | rack-pjax, rails, remotipart           |
    |                                | sass-rails, coffee-script, railties    |
    |                                | coffee-script-source, execjs           |
    |                                | actionpack, activesupport              |
    |                                | method_source, rake, thor, actionview  |
    |                                | rack, rack-test, rails-dom-testing     |
    |                                | rails-html-sanitizer, erubi            |
    |                                | concurrent-ruby, i18n, minitest        |
    |                                | tzinfo, thread_safe, nokogiri          |
    |                                | mini_portile2, loofah, crass, temple   |
    |                                | tilt, kaminari-actionview              |
    |                                | kaminari-activerecord, kaminari-core   |
    |                                | activerecord, activemodel, arel        |
    |                                | actioncable, actionmailer, activejob   |
    |                                | activestorage, bundler                 |
    |                                | sprockets-rails, nio4r                 |
    |                                | websocket-driver, websocket-extensions |
    |                                | mail, globalid, mini_mime, marcel      |
    |                                | mimemagic, sprockets, sass             |
    |             Unique to This (9) | font-awesome-rails, kaminari           |
    |                                | nested_form, rack-pjax, remotipart     |
    |                                | kaminari-actionview                    |
    |                                | kaminari-activerecord, kaminari-core   |
    |                                | bundler                                |
    +--------------------------------|----------------------------------------+

Removing the dep will only actually remove 9 gems. The rest are shared
dependencies with other gems like rails. We can also omit trees we aren't going
to remove (hi rails) by not following them:

    > bundle-stats show sass-rails --nofollow="railties,activesupport,actionpack"
    bundle-stats for sass-rails

    +--------------------------------|----------------------------------------+
    |           Depended Upon By (2) | compass-rails, rails_admin             |
    |                 Depends On (9) | railties, sass, sprockets              |
    |                                | sprockets-rails, tilt, concurrent-ruby |
    |                                | rack, actionpack, activesupport        |
    |             Unique to This (0) |                                        |
    +--------------------------------|----------------------------------------+

To consume information with a build job or somesuch, all commands can emit JSON:

    > bundle-stats show sass-rails --nofollow="railties,activesupport,actionpack" -f json
    {
      "name": "sass-rails",
      "total_dependencies": 9,
      "first_level_dependencies": 5,
      "top_level_dependencies": {
        "compass-rails": "compass-rails (3.1.0)",
        "rails_admin": "rails_admin (1.3.0)"
      },
      "transitive_dependencies": [
        "railties (< 6, >= 4.0.0)",
        "sass (~> 3.1)",
        "sprockets (< 4.0, >= 2.8)",
        "sprockets-rails (< 4.0, >= 2.0)",
        "tilt (< 3, >= 1.1)",
        "concurrent-ruby (~> 1.0)",
        "rack (< 3, > 1)",
        "actionpack (>= 4.0)",
        "activesupport (>= 4.0)"
      ],
      "potential_removals": [

      ]
    }

Contributing
------------

Contributions are very welcome. Fork, fix, submit pulls.

Contribution is expected to conform to the [Contributor Covenant](https://github.com/jmmastey/bundler-stats/blob/master/CODE_OF_CONDUCT.md).


Credits
-------

Thanks to the many kind people at [RailsCamp East
2016](http://east.railscamp.com) for the help, the ideas, and the support.

Thanks to Isaac Bowen for being pedantic about speeling.

License
-------

This software is released under the [MIT
License](https://github.com/jmmastey/bundler-stats/blob/master/MIT-LICENSE).

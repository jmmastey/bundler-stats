Bundler Stats
=============

You remember that time [someone yanked their library](http://blog.npmjs.org/post/141577284765/kik-left-pad-and-npm)
and the entire Node universe fell apart? Yeah, me too. And all the
[thinkpieces](http://www.haneycodes.net/npm-left-pad-have-we-forgotten-how-to-program/)
that came out just afterward were right: you should be careful about
what dependencies you include in your project.

This project gives you some tools you can use with an existing Gemfile to
determine which gems are including long trees of their own dependencies,
and which you can potentially remove.

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
        bundle-stats help [COMMAND]  # Describe available commands or one specific command
        bundle-stats show TARGET     # Prints the dependency tree for a single gem in your Gemfile
        bundle-stats stats           # Displays basic stats about the gems in your Gemfile
        bundle-stats version         # Prints the bundler-stats version

The most obvious thing to do is run the command by itself, which should help identify problem areas:

    > bundle-stats

    +------------------------------|-----------------|-----------------+
    | Name                         | Total Deps      | 1st Level Deps  |
    +------------------------------|-----------------|-----------------+
    ... omitted stuff here ...
    | fog                          | 15              | 6               |
    | fancybox2-rails              | 15              | 1               |
    | quiet_assets                 | 15              | 1               |
    | coffee-rails                 | 18              | 2               |
    | angular-rails-templates      | 19              | 3               |
    | devise                       | 19              | 6               |
    | rspec-rails                  | 20              | 7               |
    | sass-rails                   | 21              | 4               |
    | foundation-icons-sass-rails  | 22              | 2               |
    | rails                        | 29              | 9               |
    | angular_rails_csrf           | 30              | 1               |
    | ngannotate-rails             | 31              | 2               |
    | activeadmin                  | 48              | 12              |
    +------------------------------|-----------------|-----------------+

    Declared Gems:     35
    Total Gems:        113

    Unpinned Versions: 30
    Github Refs:       1

It looks like activeadmin is a huge problem. Use `show` to investigate:

    > bundle-stats show activeadmin
    bundle-stats for activeadmin

    depended upon by (0) |
    depends on (48)      | arbre, bourbon, coffee-rails, formtastic, formtastic_i18n, inherited_resources, jquery-rails, jquery-ui-rails, kaminari, rails, ransack, sass-rails, activesupport, i18n, json, minitest, thread_safe, tzinfo, sass, thor, coffee-script, railties, coffee-script-source, execjs, actionpack, rake, actionview, rack, rack-test, builder, erubis, has_scope, responders, actionmailer, activemodel, activerecord, bundler, sprockets-rails, mail, mime-types, treetop, polyglot, arel, sprockets, hike, multi_json, tilt, polyamorous
    unique to this (12)   | arbre, bourbon, formtastic, formtastic_i18n, inherited_resources, jquery-rails, jquery-ui-rails, kaminari, ransack, has_scope, bundler, polyamorous

Removing the dep will only actually remove 12 gems. The rest are shared dependencies with rails. We can also omit trees we aren't going to remove (hi rails) by not following them:

    > bundle-stats show sass-rails --nofollow="railties,activesupport,actionpack"
    bundle-stats for sass-rails

    depended upon by (2) | activeadmin, foundation-icons-sass-rails
    depends on (10)      | railties, sass, sprockets, sprockets-rails, hike, multi_json, rack, tilt, actionpack, activesupport
    unique to this (0)   |

To consume information with a build job or somesuch, all commands can emit JSON:

    > bundle-stats show sass-rails --nofollow="railties,activesupport,actionpack" -f json
    {
      "name": "sass-rails",
      "total_dependencies": 10,
      "first_level_dependencies": 4,
      "top_level_dependencies": {
        "activeadmin": "activeadmin (1.0.0.pre)",
        "foundation-icons-sass-rails": "foundation-icons-sass-rails (3.0.0)"
      },
      "transitive_dependencies": [
        "railties (< 5.0, >= 4.0.0)",
        "sass (~> 3.2.0)",
        "sprockets (<= 2.11.0, ~> 2.8)",
        "sprockets-rails (~> 2.0)",
        "hike (~> 1.2)",
        "multi_json (~> 1.0)",
        "rack (~> 1.0)",
        "tilt (!= 1.3.0, ~> 1.1)",
        "actionpack (>= 3.0)",
        "activesupport (>= 3.0)"
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

Thanks to the many kind people at [RailsCamp East 2016](http://east.railscamp.com)
for the help, the ideas, and the support.

Thanks to Isaac Bowen for being pedantic about speeling.

License
-------

This software is released under the [MIT License](https://github.com/jmmastey/bundler-stats/blob/master/MIT-LICENSE).

Changelog
=============

## [2.1.0] - 2021-11-29

### Changed
- Add Travis targets for more modern rubies, by @etagwerker.
- Make sorting predictable across platforms, by @etagwerker.

### Fixed
- Fix error in CI when `tput` isn't available, by @etagwerker.

## [2.0.1] - 2018-05-04

### Added
- Complete custom table printer for some nicer output.

## [2.0.0] - 2018-05-04
Broken as hell.

## [1.3.4] - 2019-04-18

### Changed
- Allow use of either `bundle-stats` or `bundler-stats` since the gem name was
  a confusing choice. Live and learn.

### Added
- Display resolved version of a gem when using `bundler-stats show`.

## [1.3.3] - 2019-04-18

### Changed
- Only print missing system dependency warning once per target gem, rather than
  blowing up the console when a complicated gem is affected.

## [1.3.2] - 2019-04-17

### Fixed
- Fix issue when testing removability and a system gem from another platform
  is "required", thx @rwojnarowski.

## [1.3.1] - 2019-04-05

### Changed
- Nicer table printing, still committed to not adding a table printing gem.

## [1.3.0] - 2019-04-05

### Changed
- Reversed the order in which gems are printed to worst-offenders-first.

## [1.2.1] - 2019-04-05

### Fixed
- When a system gem is missing from the lockfile (but is depended upon), warn
  the user rather than exploding.

## [1.2.0] - 2019-04-05

### Fixed
- Loosen dependency on thor gem, by localhostdotdev.

## [1.1.2] - 2018-03-16
Wonkiness w/ versioning. Apparently I was bad at this.

## [1.1.0] - 2018-03-16
Eventually superseded by 1.1.2 for reasons.

### Fixed
- Remove unintentional inclusion of pry outside of dev environment, per @Tuxified

## [1.1.0] - 2018-03-15

### Added
- Adds a way to view dependency version restrictions for a given gem, by @olivierlacan

## [1.0.0] - 2016-04-13

### Added
- Base library, woo!
- List all transitive dependencies and how many other deps rely on them
- View list of Github-specified dependencies
- Traverses from your current location to the Gemfile
- JSON and table outputters

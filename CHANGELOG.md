# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.2.1] - 2024-11-20

### Added

- Added Ruby 3.3.5 support
- Added Rails 8.0 support

## [3.2.0] - 2021-12-28

### Added

- Added GitHub Actions integration & badge
- Added Ruby 2.7.5 support
- Added Rails 7.0 support

### Removed

- Removed Travis-ci integration
- Remove EOL rubies from CI (ruby 1.9-2.2)

## [3.1.0] - 2021-02-17

### Added

- Added a `preprocessor` option
- Added a `postprocessor` option

### Fixed

- Ensure the initial options hash is never modified
- When using conditions in combination with array includes, ensure nested includes are not accidentally deleted

### Removed

- Removed jeweler as a gem dependency

## [3.0.0] - 2019-08-18

### Added

- Support for Ruby 2.6.3
- Support for Ruby 2.5.5
- Support for Rails 6.0

### Changed

- When using conditions, return `nil` instead of `false` as return value when a condition fails
- Refactored gem structure and include in AR using lazy load hooks
- Skip validations on save by using module `DeepCloneable::SkipValidations` instead of a code patch
- Namespace of `ActiveRecord::Base::DeepCloneable::AssociationNotFoundException` changed to `DeepCloneable::AssociationNotFoundException`
- Process optional block after all other processing has been finished

### Fixed

- Add the `validate` option to the list of passed dup options to ensure validations are never run on save

### Removed

- Official support for ruby 1.8.7, as it is not supported by Travis CI anymore
- Official support for ruby 1.9.2, as it is not supported by Travis CI anymore

## [2.4.0] - 2019-01-10

### Added

- Support `has_one` and `has_one - through`

### Changed

- Lint code via Rubocop
- Refactor code to improve readability
- Use HTTPS in the gemspec website URL

## [2.3.2] - 2018-04-11

### Added

- Support for Ruby 2.4 and 2.5
- Support for Rails 5.1 and 5.2
- CHANGELOG.md

## [2.3.1] - 2017-10-03

### Added

- Documentation on when the optional block is invoked, which is before attributes are excluded

### Fixed

- Conditional includes for nested associations

## [2.3.0] - 2017-06-14

### Added

- Support for skipping missing associations

### Fixed

- Multikey hashes in include arrays

## [2.2.2] - 2016-10-10

### Added

- Documentation on cloning associated Carrierwave files

### Changed

- Use `inverse_of` when defined for finding the reverse association
- Cache bundler in Travis
- Use index operator for setting column defaults
- Explicitly require activerecord to resolve a sidekiq issue
- Bump rails 5.0 appraisal

## [2.2.1] - 2016-05-27

### Fixed

- Properly set column defaults for attributes
- Rails 5.0 compatibility

## [2.2.0] - 2016-01-11

### Added

- Support for conditional cloning when using array inclusions

### Changed

- Bump rails 4.2 appraisal to 4.2.3

## [2.1.0] - 2015-03-10

### Added

- Support for conditional cloning

### Changed

- Check the dictionary before cloning has_many through or habtm associations
- Refactor methods to refer to `dup` instead of `clone`

## [2.0.2] - 2014-12-17

### Fixed

- Broken activerecord dependency in gemspec

## [2.0.1] - 2014-12-17

### Fixed

- Rails 4.2.0.rc3 compatibility

## [2.0.0] - 2014-06-26

### Removed

- Override of `dup`
- References to `dup`

### Fixed

- Open-ended dependency warning

## [1.7.0] - 2014-06-25

### Deprecated

- Deprecated `dup` in favor of `deep_clone`

## [1.6.1] - 2014-04-16

### Changed

- Switched test suite to minitest
- Update travis.yml with rails 4.1

### Fixed

- Rails 4.1 compatibility

## [1.6.0] - 2013-11-02

### Added

- `:only` option for whitelisting attributes
- MIT license

## [1.5.5] - 2013-08-28

### Fixed

- Fix activerecord gem dependency

## [1.5.4] - 2013-08-12

### Removed

- Rails 3.0 support, as it was broken anyway

### Changed

- Update travis.yml with rails 4.0

### Fixed

- Appraisals should load the correct major version of rails
- Exclude unsupported builds in Travis

## [1.5.3] - 2013-06-18

### Fixed

- Fix `initialize_dup` error

## [1.5.2] - 2013-06-10

### Fixed

- Properly support has_many through associations
- Fix reverse association lookup for self-referential models
- Travis.ci status image

## [1.5.1] - 2013-03-06

### Fixed

- Ruby 2.0 compatibility

## [1.5.0] - 2013-02-27

### Added

- `:validate` option to disable validations when saving a cloned object

### Fixed

- Depend on activerecord instead of rails

## [1.4.1] - 2012-07-23

### Fixed

- Don't save HABTM associations on clone

## [1.4.0] - 2012-04-02

### Added

- Possibility to add a optional block

### Fixed

- Ruby 1.8.7 compatibility for rails 3.1

## [1.3.1] - 2012-01-26

### Fixed

- Rails 3.2 compatibility

## [1.2.4] - 2011-06-15

### Changed

- Raise an exception when the reverse association is missing

### Fixed

- Reset column value when cloning associations

## [1.2.3] - 2011-02-27

### Changed

- Find and set the reverse association when cloning associations

## [1.2.2] - 2011-02-21

### Fixed

- Use association reflection for fetching the primary key name

## [1.2.1] - 2011-02-07

### Fixed

- Cloning for polymorphic associations

## [1.2.0] - 2010-10-20

### Added

- `:except` option for excluding attributes

### Fixed

- Set foreign keys properly

## 1.0.0 - 2010-10-18

### Fixed

- Convert existing code to a gem

[unreleased]: https://github.com/moiristo/deep_cloneable/compare/v3.2.1...HEAD
[3.2.1]: https://github.com/moiristo/deep_cloneable/compare/v3.2.0...v3.2.1
[3.2.0]: https://github.com/moiristo/deep_cloneable/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/moiristo/deep_cloneable/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/moiristo/deep_cloneable/compare/v2.4.0...v3.0.0
[2.4.0]: https://github.com/moiristo/deep_cloneable/compare/v2.3.2...v2.4.0
[2.3.2]: https://github.com/moiristo/deep_cloneable/compare/v2.3.1...v2.3.2
[2.3.1]: https://github.com/moiristo/deep_cloneable/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/moiristo/deep_cloneable/compare/v2.2.2...v2.3.0
[2.2.2]: https://github.com/moiristo/deep_cloneable/compare/v2.2.1...v2.2.2
[2.2.1]: https://github.com/moiristo/deep_cloneable/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/moiristo/deep_cloneable/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/moiristo/deep_cloneable/compare/v2.0.2...v2.1.0
[2.0.2]: https://github.com/moiristo/deep_cloneable/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/moiristo/deep_cloneable/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/moiristo/deep_cloneable/compare/v1.7.0...v2.0.0
[1.7.0]: https://github.com/moiristo/deep_cloneable/compare/v1.6.1...v1.7.0
[1.6.1]: https://github.com/moiristo/deep_cloneable/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/moiristo/deep_cloneable/compare/v1.5.5...v1.6.0
[1.5.5]: https://github.com/moiristo/deep_cloneable/compare/v1.5.4...v1.5.5
[1.5.4]: https://github.com/moiristo/deep_cloneable/compare/v1.5.3...v1.5.4
[1.5.3]: https://github.com/moiristo/deep_cloneable/compare/v1.5.2...v1.5.3
[1.5.2]: https://github.com/moiristo/deep_cloneable/compare/v1.5.1...v1.5.2
[1.5.1]: https://github.com/moiristo/deep_cloneable/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/moiristo/deep_cloneable/compare/v1.4.1...v1.5.0
[1.4.1]: https://github.com/moiristo/deep_cloneable/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/moiristo/deep_cloneable/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/moiristo/deep_cloneable/compare/v1.2.4...v1.3.1
[1.2.4]: https://github.com/moiristo/deep_cloneable/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/moiristo/deep_cloneable/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/moiristo/deep_cloneable/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/moiristo/deep_cloneable/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/moiristo/deep_cloneable/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/moiristo/deep_cloneable/compare/v1.0.0...v1.1.0

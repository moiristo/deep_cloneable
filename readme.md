# deep_cloneable

[![Build Status](https://travis-ci.org/moiristo/deep_cloneable.svg?branch=master)](https://travis-ci.org/moiristo/deep_cloneable)

This gem gives every ActiveRecord::Base object the possibility to do a deep clone that includes user specified associations. It is a rails 3+ upgrade of the [deep_cloning plugin](http://github.com/openminds/deep_cloning).

## Requirements

* Ruby 1.8.7, 1.9.2, 1.9.3, 2.0.0, 2.1.5, 2.2.2, 2.3.0 (tested)
* Activerecord 3.1, 3.2, 4.0, 4.1, 4.2, 5.0.0.1 (tested)
* Rails 2.x/3.0 users, please check out the 'rails2.x-3.0' branch

## Installation

* Add deep_cloneable to your Gemfile:

```ruby
gem 'deep_cloneable', '~> 2.3.0'
```

## Upgrading from v1

The `dup` method with arguments has been replaced in deep_cloneable 2 by the method `deep_clone`. Please update your sources accordingly.

## Usage

The `deep_clone` method supports a couple options that can be specified by passing an options hash. Without options, the behaviour is the same as ActiveRecord's  [`dup`](http://apidock.com/rails/ActiveRecord/Core/dup) method.

### Association inclusion

Associations to be included in the dup can be specified with the `include` option:

```ruby
# Single include
pirate.deep_clone include: :mateys

# Multiple includes
pirate.deep_clone include: [ :mateys, :treasures ]

# Deep includes
pirate.deep_clone include: { treasures: :gold_pieces }
pirate.deep_clone include: [ :mateys, { treasures: :gold_pieces } ]

# Disable validation for a performance speedup when saving the dup
pirate.deep_clone include: { treasures: :gold_pieces }, validate: false

# Conditional includes
pirate.deep_clone include: [
  {
    treasures: { gold_pieces: { if: lambda{|piece| piece.is_a?(Parrot) } } } },
    mateys: { unless: lambda{|matey| matey.is_a?(GoldPiece) }
  }
]

ship.deep_clone include: [
  pirates: [ :treasures, :mateys, if: lambda {|pirate| pirate.name == 'Jack Sparrow' } ]
]
```

#### The Dictionary (Object Reusage)

The dictionary ensures that models are not duped multiple times when it is associated to nested models. It does this by storing a mapping of the original object to its duped object. It can be used as follows:

```ruby
# Enables the dictionary (empty on initialization)
pirate.deep_clone include: [ :mateys, { treasures:  [ :matey, :gold_pieces ] } ], use_dictionary: true

# Deep clones with a prefilled dictionary
dictionary = { mateys: {} }
pirate.mateys.each{|m| dict[:mateys][m] = m.deep_clone }
pirate.deep_clone include: [ :mateys, { treasures: [ :matey, :gold_pieces ] } ], dictionary: dictionary
```

### Attribute Exceptions & Inclusions

The `deep_clone` method supports both `except` and `only` for specifying which attributes should be duped:

#### Exceptions
```ruby
# Single exception
pirate.deep_clone except: :name

# Multiple exceptions
pirate.deep_clone except: [ :name, :nick_name ]

# Nested exceptions
pirate.deep_clone include: :parrot, except: [ :name, { parrot: [ :name ] } ]
```

#### Inclusions
```ruby
# Single attribute inclusion
pirate.deep_clone only: :name

# Multiple attribute inclusions
pirate.deep_clone only: [ :name, :nick_name ]

# Nested attribute inclusions
pirate.deep_clone include: :parrot, only: [ :name, { parrot: [ :name ] } ]

```

### Optional Block

Pass a block to `deep_clone` to modify a duped object after duplication:

```ruby
pirate.deep_clone include: :parrot do |original, kopy|
  kopy.cloned_from_id = original.id if kopy.respond_to?(:cloned_from_id)
end
```

*Note*: The block is invoked before attributes are excluded.

*Note*: Using `deep_clone` with a block will also pass the associated objects that are being cloned to the block, so be sure to check whether the object actually responds to your method of choice.

### Cloning models with files associated through Carrierwave

If you are cloning models that have associated files through Carrierwave these will not get transferred automatically. To overcome the issue you need to explicitly set the file attribute.

Easiest solution is to add the code in a clone block as described above.
```ruby
pirate.deep_clone include: :parrot do |original, kopy|
  kopy.thumbnail = original.thumbnail
end
```

### Skipping missing associations

By default, deep_cloneable will throw a `ActiveRecord::Base::DeepCloneable::AssociationNotFoundException` error when an association cannot be found. You can also skip missing associations by specifying `skip_missing_associations` if needed, for example when you have associations on some (but not all) subclasses of an STI model:

```ruby
pirate.deep_clone include: [:parrot, :rum], skip_missing_associations: true
```

### Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

### Copyright

Copyright &copy; 2017 Reinier de Lange. See LICENSE for details.

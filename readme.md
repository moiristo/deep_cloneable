# deep_cloneable

![Build Status](https://github.com/moiristo/deep_cloneable/actions/workflows/ruby.yml/badge.svg)

This gem gives every ActiveRecord::Base object the possibility to do a deep clone that includes user specified associations. It is a rails 3+ upgrade of the [deep_cloning plugin](http://github.com/openminds/deep_cloning).

## Requirements

- Ruby 2.3.0, 2.4.4, 2.5.5, 2.6.3, 2.7.5 (tested)
- TruffleRuby 21.3.0
- Activerecord 3.2, 4.0, 4.1, 4.2, 5.0, 5.1, 5.2, 6.0, 7.0 (tested)
- Rails 2.x/3.0 users, please check out the 'rails2.x-3.0' branch

## Installation

- Add deep_cloneable to your Gemfile:

```ruby
gem 'deep_cloneable', '~> 3.2.0'
```

## Upgrade details

### Upgrading from v2

There are two breaking changes that you might need to pay attention to:

- When using an optional block (see below), the block used to be evaluated before `deep_cloneable` had performed its changes (inclusions, exclusions, includes). In v3, the block is evaluated after all processing has been done, just before the copy is about to be returned.
- When a defined association is not found, `deep_cloneable` raises an exception. The exception class has changed namespace: the class definition used to be `ActiveRecord::Base::DeepCloneable::AssociationNotFoundException` and this has changed to `DeepCloneable::AssociationNotFoundException`.

### Upgrading from v1

The `dup` method with arguments has been replaced in deep_cloneable 2 by the method `deep_clone`. Please update your sources accordingly.

## Usage

The `deep_clone` method supports a couple options that can be specified by passing an options hash. Without options, the behaviour is the same as ActiveRecord's [`dup`](http://apidock.com/rails/ActiveRecord/Core/dup) method.

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

### Pre- and postprocessor

You can specify a pre- and/or a postprocessor to modify a duped object after duplication:

```ruby
pirate.deep_clone(include: :parrot, preprocessor: ->(original, kopy) { kopy.cloned_from_id = original.id if kopy.respond_to?(:cloned_from_id) })
pirate.deep_clone(include: :parrot, postprocessor: ->(original, kopy) { kopy.cloned_from_id = original.id if kopy.respond_to?(:cloned_from_id) })
```

_Note_: Specifying a postprocessor is essentially the same as specifying an optional block (see below).

_Note_: Using `deep_clone` with a processors will pass all associated objects that are being cloned to the processor, so be sure to check whether the object actually responds to your method of choice.

### Optional Block

Pass a block to `deep_clone` to modify a duped object after duplication:

```ruby
pirate.deep_clone include: :parrot do |original, kopy|
  kopy.cloned_from_id = original.id if kopy.respond_to?(:cloned_from_id)
end
```

_Note_: Using `deep_clone` with a block will also pass the associated objects that are being cloned to the block, so be sure to check whether the object actually responds to your method of choice.

### Cloning models with files

#### Carrierwave

If you are cloning models that have associated files through Carrierwave these will not get transferred automatically. To overcome the issue you need to explicitly set the file attribute.

Easiest solution is to add the code in a clone block as described above.

```ruby
pirate.deep_clone include: :parrot do |original, kopy|
  kopy.thumbnail = original.thumbnail
end
```

#### ActiveStorage

For ActiveStorage, you have two options: you can either make a full copy, or share data blobs between two records.

##### Full copy example

```ruby
# Rails 5.2, has_one_attached example 1
pirate.deep_clone include: [:parrot, :avatar_attachment, :avatar_blob]

# Rails 5.2, has_one_attached example 2
pirate.deep_clone include: :parrot do |original, kopy|
  if kopy.is_a?(Pirate) && original.avatar.attached?
    attachment = original.avatar
    kopy.avatar.attach \
      :io           => StringIO.new(attachment.download),
      :filename     => attachment.filename,
      :content_type => attachment.content_type
  end
end

# Rails 5.2, has_many_attached example 1 (attach one by one)
pirate.deep_clone include: :parrot do |original, kopy|
  if kopy.is_a?(Pirate) && original.crew_members_images.attached?
    original.crew_members_images.each do |attachment|
      kopy.crew_members_images.attach \
        :io           => StringIO.new(attachment.download),
        :filename     => attachment.filename,
        :content_type => attachment.content_type
    end
  end
end

# Rails 5.2, has_many_attached example 2 (attach bulk)
pirate.deep_clone include: :parrot do |original, kopy|
  if kopy.is_a?(Pirate) && original.crew_members_images.attached?
    all_attachments_arr = original.crew_members_images.map do |attachment|
      {
        :io           => StringIO.new(attachment.download),
        :filename     => attachment.filename,
        :content_type => attachment.content_type
      }
    end
    kopy.crew_members_images.attach(all_attachments_arr) # attach all at once
  end
end

# Rails 6
pirate.deep_clone include: :parrot do |original, kopy|
  if kopy.is_a?(Pirate) && original.avatar.attached?
    original.avatar.open do |tempfile|
      kopy.avatar.attach({
        io: File.open(tempfile.path),
        filename: original.avatar.blob.filename,
        content_type: original.avatar.blob.content_type
      })
    end
  end
end
```

##### Shallow copy example

```ruby
pirate.deep_clone include: :parrot do |original, kopy|
  kopy.avatar.attach(original.avatar.blob) if kopy.is_a?(Pirate) && original.avatar.attached?
end
```

### Skipping missing associations

By default, deep_cloneable will throw a `DeepCloneable::AssociationNotFoundException` error when an association cannot be found. You can also skip missing associations by specifying `skip_missing_associations` if needed, for example when you have associations on some (but not all) subclasses of an STI model:

```ruby
pirate.deep_clone include: [:parrot, :rum], skip_missing_associations: true
```

### Note on Patches/Pull Requests

- Fork the project.
- Make your feature addition or bug fix.
- Add tests for it. This is important so I don't break it in a
  future version unintentionally.
- Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
- Send me a pull request. Bonus points for topic branches.

### Copyright

Copyright &copy; 2021 Reinier de Lange. See LICENSE for details.

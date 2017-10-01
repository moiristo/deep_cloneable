ActiveRecord::Schema.define(:version => 1) do
  create_table :pirates, :force => true do |t|
    t.column :name, :string
    t.column :nick_name, :string, :default => 'no nickname'
    t.column :age, :string
    t.column :ship_id, :integer
    t.column :ship_type, :string
    t.column :piastres, :text, :default => [].to_yaml
  end

  create_table :parrots, :force => true do |t|
    t.column :name, :string
    t.column :age, :integer
    t.column :pirate_id, :integer
  end

  create_table :mateys, :force => true do |t|
    t.column :name, :string
    t.column :pirate_id, :integer
  end

  create_table :treasures, :force => true do |t|
    t.column :found_at, :string
    t.column :owner, :integer
    t.column :matey_id, :integer
  end

  create_table :cages, :force => true do |t|
    t.column :name, :string
    t.column :owner_id, :integer
  end

  create_table :gold_pieces, :force => true do |t|
    t.column :treasure_id, :integer
  end

  create_table :battle_ships, :force => true do |t|
    t.column :name, :string
  end

  create_table :pigs, :force => true do |t|
    t.column :name, :string
    t.column :human_id, :integer
  end

  create_table :humen, :force => true do |t|
    t.column :name, :string
  end

  create_table :planets, :force => true do |t|
    t.column :name, :string
  end

  create_table :birds, :force => true do |t|
    t.column :name, :string
    t.column :type, :string
    t.column :planet_id, :integer
  end

  create_table :ownerships, :force => true do |t|
    t.column :human_id, :integer
    t.column :chicken_id, :integer
  end

  create_table :cars, :force => true do |t|
    t.column :name, :string
  end

  create_table :coins, :force => true do |t|
    t.column :value, :integer
  end

  create_table :people, :force => true do |t|
    t.column :name, :string
  end

  create_table :cars_people, :id => false, :force => true do |t|
    t.column :car_id, :integer
    t.column :person_id, :integer
  end

  create_table :coins_people, :id => false, :force => true do |t|
    t.column :coin_id, :integer
    t.column :person_id, :integer
  end

  create_table :parent_with_validations, :force => true do |t|
    t.column :name, :string
  end

  create_table :child_with_validations, :force => true do |t|
    t.column :name, :string
    t.column :parent_with_validation_id, :integer
  end

  create_table :parts, :force => true do |t|
    t.column :name, :string
    t.column :parent_part_id, :integer
  end

  create_table :students, :force => true do |t|
    t.column :name, :string
  end

  create_table :subjects, :force => true do |t|
    t.column :name, :string
  end

  create_table :student_assignments, :force => true do |t|
    t.column :student_id, :integer
    t.column :subject_id, :integer
  end

  create_table :buildings, :force => true do |t|
    t.column :name, :string
  end

  create_table :apartments, :force => true do |t|
    t.column :number, :string
    t.column :building_id, :integer
  end

  create_table :contractors, :force => true do |t|
    t.column :name, :string
    t.column :building_id, :integer
  end

  create_table :apartments_contractors, :force => true do |t|
    t.column :apartment_id, :integer
    t.column :contractor_id, :integer
  end

  create_table :users, :force => true do |t|
    t.column :name, :string
    t.column :contractor_id, :integer
  end

  create_table :orders, :force => true do |t|
    t.column :user_id, :integer
  end

  create_table :products, :force => true do |t|
    t.column :name, :string
    t.column :order_id, :integer
  end
end

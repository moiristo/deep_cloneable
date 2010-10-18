ActiveRecord::Schema.define(:version => 1) do
  create_table :pirates, :force => true do |t|
    t.column :name, :string
    t.column :nick_name, :string, :default => 'no nickname'
    t.column :age, :string
  end
  
  create_table :parrots, :force => true do |t|
    t.column :name, :string
    t.column :pirate_id, :integer
  end
  
  create_table :mateys, :force => true do |t|
    t.column :name, :string
    t.column :pirate_id, :integer
  end
  
  create_table :treasures, :force => true do |t|
    t.column :found_at, :string
    t.column :pirate_id, :integer
  end
  
  create_table :gold_pieces, :force => true do |t|
    t.column :treasure_id, :integer
  end
end

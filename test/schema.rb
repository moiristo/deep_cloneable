ActiveRecord::Schema.define(:version => 1) do
  create_table :pirates, :force => true do |t|
    t.column :name, :string
    t.column :nick_name, :string, :default => 'no nickname'
    t.column :age, :string
    t.column :ship_id, :integer
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
    t.column :owner, :integer
    t.column :matey_id, :integer    
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
  
  create_table :chickens, :force => true do |t|
    t.column :name, :string
  end  
  
  create_table :ownerships, :force => true do |t|
    t.column :human_id, :integer
    t.column :chicken_id, :integer    
  end  
  
end

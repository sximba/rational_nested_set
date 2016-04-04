ActiveRecord::Schema.define(:version => 0) do

  create_table :default_scoped_models, :force => true do |t|
    t.column :name, :string
    t.column :parent_id, :integer
    t.column :numv, :integer
    t.column :denv, :integer
    t.column :snumv, :integer
    t.column :sdenv, :integer
    t.column :total_order, :float
    t.column :depth, :integer
    t.column :is_leaf, :boolean
  end

  create_table :categories, :force => true do |t|
    t.column :name, :string
    t.column :parent_id, :integer
    t.column :numv, :integer
    t.column :denv, :integer
    t.column :snumv, :integer
    t.column :sdenv, :integer
    t.column :total_order, :float
    t.column :depth, :integer
    t.column :is_leaf, :boolean
    t.column :organization_id, :integer
  end

  create_table :departments, :force => true do |t|
    t.column :name, :string
  end

  create_table :notes, :force => true do |t|
    t.column :body, :text
    t.column :parent_id, :integer
    t.column :numv, :integer
    t.column :denv, :integer
    t.column :snumv, :integer
    t.column :sdenv, :integer
    t.column :total_order, :float
    t.column :depth, :integer
    t.column :is_leaf, :boolean
    t.column :notable_id, :integer
    t.column :notable_type, :string
    t.column :user_id, :integer
  end

  create_table :renamed_columns, :force => true do |t|
    t.column :name, :string    
    t.column :mother_id, :integer
    t.column :orange, :integer
    t.column :yellow, :integer
    t.column :green, :integer
    t.column :blue, :integer
    t.column :violet, :float
    t.column :indigo, :integer
    t.column :purple, :boolean
  end

  create_table :things, :force => true do |t|
    t.column :body, :text
    t.column :parent_id, :integer
    t.column :numv, :integer
    t.column :denv, :integer
    t.column :snumv, :integer
    t.column :sdenv, :integer
    t.column :total_order, :float
    t.column :depth, :integer
    t.column :is_leaf, :boolean
    t.column :children_count, :integer
  end

  create_table :brokens, :force => true do |t|
    t.column :name, :string
    t.column :parent_id, :integer
    t.column :numv, :integer
    t.column :denv, :integer
    t.column :snumv, :integer
    t.column :sdenv, :integer
    t.column :total_order, :float
    t.column :depth, :integer
    t.column :is_leaf, :boolean
  end

  create_table :orders, :force => true do |t|
    t.column :name, :string
    t.column :parent_id, :integer
    t.column :numv, :integer
    t.column :denv, :integer
    t.column :snumv, :integer
    t.column :sdenv, :integer
    t.column :total_order, :float
    t.column :depth, :integer
    t.column :is_leaf, :boolean
  end

  create_table :positions, :force => true do |t|
    t.column :name, :string
    t.column :parent_id, :integer
    t.column :numv, :integer
    t.column :denv, :integer
    t.column :snumv, :integer
    t.column :sdenv, :integer
    t.column :total_order, :float
    t.column :depth, :integer
    t.column :is_leaf, :boolean
    t.column :position, :integer
  end

  create_table :no_depths, :force => true do |t|
    t.column :name, :string
    t.column :parent_id, :integer
    t.column :numv, :integer
    t.column :denv, :integer
    t.column :snumv, :integer
    t.column :sdenv, :integer
    t.column :total_order, :float
    t.column :is_leaf, :boolean
  end

  create_table :single_table_inheritance, :force => true do |t|
    t.column :type, :string
    t.column :name, :string
    t.column :parent_id, :integer
    t.column :numv, :integer
    t.column :denv, :integer
    t.column :snumv, :integer
    t.column :sdenv, :integer
    t.column :total_order, :float
    t.column :is_leaf, :boolean
  end

  create_table :users, :force => true do |t|
    t.column :uuid, :string
    t.column :name, :string    
    t.column :parent_uuid, :string
    t.column :numv, :integer
    t.column :denv, :integer
    t.column :snumv, :integer
    t.column :sdenv, :integer
    t.column :total_order, :float
    t.column :depth, :integer
    t.column :is_leaf, :boolean
    t.column :organization_id, :integer
  end
end

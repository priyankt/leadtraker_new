migration 8, :create_expenses do
  up do
    create_table :expenses do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :expenses
  end
end

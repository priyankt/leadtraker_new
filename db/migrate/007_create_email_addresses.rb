migration 7, :create_email_addresses do
  up do
    create_table :email_addresses do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :email_addresses
  end
end

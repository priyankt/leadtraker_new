migration 17, :create_sms_patterns do
  up do
    create_table :sms_patterns do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :sms_patterns
  end
end

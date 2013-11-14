migration 12, :create_leads do
  up do
    create_table :leads do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :leads
  end
end

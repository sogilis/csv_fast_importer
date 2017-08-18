class CreateKnights < ActiveRecord::Migration
  def change
    create_table :knights do |t|
      t.string :name
      t.string :email
    end
  end
end

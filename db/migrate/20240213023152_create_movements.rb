class CreateMovements < ActiveRecord::Migration[7.1]
  def change
    create_table :movements do |t|
      t.string :name
      t.decimal :amount
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateSubtitles < ActiveRecord::Migration
  def change
    create_table :subtitles do |t|
      t.string :filename
      t.text :original
      t.text :translated

      t.timestamps null: false
    end
  end
end

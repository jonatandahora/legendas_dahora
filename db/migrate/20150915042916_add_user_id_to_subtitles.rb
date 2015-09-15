class AddUserIdToSubtitles < ActiveRecord::Migration
  def change
    add_reference :subtitles, :user, index: true, foreign_key: true
  end
end

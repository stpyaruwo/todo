require "active_record"

#アクティブレコードから、テーブルを追加したり、検索したりする
module Todo

  #tasksテーブルを表現するモデルクラスです。
  # @author nagami
  class Task < ActiveRecord::Base

    scope :status_is, ->(status) { where(status: status) }

    NOT_YET = 0 #タスクが完了していない
    DONE = 1 #タスクが完了した
    PENDING = 2 #保留状態のタスク

    STATUS = {
      'NOT_YET' => NOT_YET,
      'DONE' => DONE,
      'PENDING' => PENDING
    }.freeze

    def status_name
      STATUS.key(self.status)
    end
    #入力チェック
    validates :name, presence: true,length: {maximum: 140}
    validates :content, presence: true
    validates :status, numericality: true,inclusion: {in: STATUS.values}

  end
end

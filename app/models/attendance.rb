class Attendance < ApplicationRecord
  belongs_to :user
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
   # 出勤時間が存在しない場合、退勤時間は無効
   # *呼び出し側でvalidateメソッドと記述している点には注意してください 
   # *存在性の検証などではvalidatesのようにsが入りましたが、今回のパターンだと不要(メソッド内で検証してるから)なのでsが入らずvalidate
  validate :finished_at_is_invalid_without_a_started_at
   # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid
  
  
  # blank?は対象がnil "" " " [] {}のいずれかでtrueを返します。present?はその逆（値が存在する場合）にtrueを返します→true or falseで返す
  # ※precenceとprecent?の違い　precenceはtrueの時、レシーバ自身を返し(検証対象をそのまま返す)、false のときは nil を返すメソッド
  # 「出勤時間が無い、かつ退勤時間が存在する場合」、trueとなって処理が実行されるわけです
  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
end

module AttendancesHelper
  # テキスト勤怠10.6参照：渡される引数は、繰り返し処理されているAttendanceモデルオブジェクトを想定しています。
  # このメソッドを使って勤怠登録ボタンのテキストには何が必要か？または必要ないか？」をこのメソッドで判定することです。
  # このメソッドでは戻り値が3パターン ⓵「勤怠データが当日、かつ出勤時間が存在しない場合」に'出勤'
  # ➁勤怠データが当日、かつ出勤時間が登録済、かつ退勤時間が存在しない場合」に'退勤'
  # ➂「勤怠データが当日ではない、または当日だが出勤時間も退勤時間も登録済の場合」にfalse  →何も起こらない
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end

end

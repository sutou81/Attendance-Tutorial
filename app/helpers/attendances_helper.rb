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
  
  # 出勤時間と退社時間を受け取り、在社時間を計算して返します。
  # %.2fの説明:%→整数、2f→小数点2桁
  # 受け取った引数(start, finish)を使って時間の計算処理をして値を返す仕組み
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end

end

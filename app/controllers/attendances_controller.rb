class AttendancesController < ApplicationController
  # ↓定数→変数とは違い、値を変えることはできません。大文字表記
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    # attributesについてupdate_attributes(勤怠4章4. 3. 3参照)メソッドは、カラムと値のハッシュを引数として受け取り、更新に成功する場合に保存を同時に実行します(検証性あり)。
    # 特定のカラムのみを更新したい場合はupdate_attribute(勤怠7章7. 1. 2参照)メソッドを使用します。このメソッドは検証を回避する性質もあります
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
end

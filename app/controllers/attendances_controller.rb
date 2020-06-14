class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  
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
  
  def edit_one_month
  end
  
  # update_attributesの末尾に!が付いていることがとても重要
  # →今回のように!をつけている場合はfalseでは無く例外処理(rescue～文)を返します。
  # トランザクションを含めた説明:勤怠11章11.3.2 同じ物：勤怠10章のset_one_month application_controllerにある
  # →attendances_params～最初のend:ここに記述したデータベース操作命令にトランザクションを適用する
  # →flash[:succes]～最初のredirect：全ての繰返し処理が問題なく完了した時は、この部分の処理が実行
  # →rescue～：例外が発生した時は、この部分が実行
  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
  flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
  redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  private
    # ストロングパラメータとは、RailsでDBを更新する際に、不要なパラメータを取り除く(必要なパラメータだけに絞り込む)ための仕組みです。(勤怠5章5.3.3にもある)
    # ストロングパラメータを使うことで、本来ユーザーから送られてくることのないパラメータが存在していたとしても、それを取り除いて安全にDBの更新を行うことができます。
    # １ヶ月分の勤怠情報を扱います。
    # 下記のコードの説明：勤怠11章11.2を見ると良くわかる　必ず参照すること
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    # beforeフィルター
    
   # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
    
end

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  # %w{日 月 火 水 木 金 土}はRubyのリテラル表記と呼ばれるものです。
  # ["日", "月", "火", "水", "木", "金", "土"]の配列と同じように使えます。
  # $変数名 →グローバル変数 グローバル変数は極端に言うとプログラムのどこからでも呼び出すことのできる変数で
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  # beforeフィルター(logged_in_userメソッドはprivateキーワード下に定義しました)

    # paramsハッシュからユーザーを取得します。
    def set_user
      @user = User.find(params[:id])
    end
    
    # ログイン済みのユーザーか確認します。
    # logged_in?:sessions_helper.rbにメソッド詳細記述あり　勤怠7.1.3参照
    #上記の補足 unless logged_in?は現在ログインしていないユーザーだった場合下記を実行
    def logged_in_user
      unless logged_in?
       store_location
       flash[:danger] = "ログインしてください。"
       redirect_to login_url
      end
    end
   
    
    # アクセスしたユーザーが現在ログインしているユーザーか確認します。
    def correct_user
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # システム管理権限所有かどうか判定します。
    def admin_user
      redirect_to root_url unless current_user.admin?
      
    end
  
  
   # ↓ページ出力前に1ヶ月分のデータの存在を確認・セットします。
   # 実行する内容(one_month.each文)　1ヵ月分の日付が繰り返されて実行されており、createメソッドによってworked_onに日付の値が入ったAttendanceモデルにデータが生成される
  def set_one_month 
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    # @attendanceの文の説明全体的意味:1ヵ月分のユーザーに紐付く勤怠データを検索し取得する 
    # @userは設定されていないように見えるけどset_userメソッドも設定されている。但しこのset_userは今回定義したset_one_monthよりも上に記述することで、before_actionの中でも優先的に実行されることになります
    #  attendancesの意味:Userモデルに紐付くモデルを指定する→Attendanceモデルを意味し、 UserモデルとAttendanceモデルは 1対多の関係なので attendancesと複数形になる
   
    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        # unless以下の文 1ヵ月分の日付の件数と勤怠データの件数が一致しなかった時実行する
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
    end
# トランザクションの説明→全部成功したことを保証するため機能
 #まとめてデータを保存や更新するときに、全部成功したことを保証するための機能
# 万が一途中で失敗した時は、エラー発生時専用のプログラム部分までスキップする
# 1ヵ月分の日付が繰り返されて実行されておりone_month.eachの文の処理がトランザクションのブロックで囲まれてる　
   # トランザクションの処理が、失敗した時は、エラー発生時専用のプログラム(rescueで始まる文)部分的までスキップされ　フラッシュメッセージとredirectが実行される
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
end 
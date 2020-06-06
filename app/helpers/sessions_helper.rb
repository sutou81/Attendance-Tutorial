module SessionsHelper

  # 引数に渡されたユーザーオブジェクトでログインします。
  def log_in(user)
    session[:user_id] = user.id
  end

  # 永続的セッションを記憶します（Userモデルを参照）
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 永続的セッションを破棄します
  def forget(user)
    user.forget # Userモデル参照
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # セッションと@current_userを破棄します
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # 一時的セッションにいるユーザーを返します。
  # それ以外の場合はcookiesに対応するユーザーを返します。
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

   # 渡されたユーザーがログイン済みのユーザーであればtrueを返します。
    def current_user?(user)
      user == current_user    
    end
    
  # 現在ログイン中のユーザーがいればtrue、そうでなければfalseを返します。
  def logged_in?
    !current_user.nil?
  end
  
  # 記憶しているURL(またはデフォルトURL)にリダイレクトします。
  def redirect_back_or(default_url)
    redirect_to(session[:fowarding_url] || default_url)
    session.delete(:fowarding_url)
    #session～の補足：ここで記憶したURLを削除しておかないと、次回ログインした時にも記憶され
    #上記の続き：ているURLへ転送されてしまいます。この状態がブラウザを閉じるまで続いてしまうわけです。
  end
  
  # アクセスしようとしたURLを記憶します。
  def store_location
    # ↓のrequest説明:現在のURLの情報を知りたい時に
    #上記の続き：Ruby on Railsでは、各種URLを取得する方法が用意されています。
    #続き2：requestオブジェクト（requestオブジェクトをビューかコントローラ内のコードで使うと）取得できます
    #続き3：original.urlで現在のURLを全部格納できる
    #参照：https://techacademy.jp/magazine/31188
    session[:fowarding_url] = request.original_url if request.get? #ページへのアクセスのみを記憶するためrequest.get?を条件式に指定してGETリクエストのみを記憶するように記述
  end
end
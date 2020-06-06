class UsersController < ApplicationController
  before_action :set_user,only: [:show, :edit, :update]
  #before-action(Ruby on Rails 簡単なSNSアプリを作ろう８章8.9に説明あり参照)の設定する必要理由
  #→⓵本来ユーザー情報更新ページに行くにはログインする必要がある
  #➁しかしトップページのURLの末尾に ex  users/1/edit と入力するとログインなしで飛べてしまう
  #➂それではセキュリティ上問題があるので各アクションに飛ぶまえにbefore-actionを設定し
  #ログインなしでユーザー情報更新ページへ飛ぶことができるのを回避しようとする為に設定
  before_action :logged_in_user, only: [:show, :edit, :update]
  #correct_userメソッドを定義し、アクセスしたユーザーが現在ログインしているユーザーであるか確認するよう判定
  before_action :correct_user, only: [:edit, :update]
  
  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # beforeフィルター(logged_in_userメソッドはprivateキーワード下に定義しました)

    # paramsハッシュからユーザーを取得します。
    def set_user
      @user = User.find(params[:id])
    end
    
    # ログイン済みのユーザーか確認します。
    # logged_in?:sessions_helper.rbにメソッド詳細記述あり　勤怠7.1.3参照
      #上記の補足 unless logged_in?は現在ログインしていないのユーザーだった場合下記を実行
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
end
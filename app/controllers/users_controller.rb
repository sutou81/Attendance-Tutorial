class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  #before-action(Ruby on Rails 簡単なSNSアプリを作ろう８章8.9に説明あり参照)の設定する必要理由
  #→⓵本来ユーザー情報更新ページに行くにはログインする必要がある
  #➁しかしトップページのURLの末尾に ex  users/1/edit と入力するとログインなしで飛べてしまう
  #➂それではセキュリティ上問題があるので各アクションに飛ぶまえにbefore-actionを設定し
  #ログインなしでユーザー情報更新ページへ飛ぶことができるのを回避しようとする為に設定
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  #correct_userメソッドを定義し、アクセスしたユーザーが現在ログインしているユーザーであるか確認するよう判定
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  #indexの中身詳細:勤怠8章8.4.2参照
  def index
    @users = User.paginate(page: params[:page])
  end
  
  # 1ヶ月分の勤怠データの中で、出勤時間が何も無い状態では無いものの数を代入
  def show
   @worked_sum = @attendances.where.not(started_at: nil).count
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
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  private
    
    # user_paramsとbasic_info_paramsの補足　下記
    # ↓Strong Parametersを用いることで、必須となるパラメータと許可されたパラメータを指定することができます。
    # つまり下記の様に指定することにより、下記のカラムのみデータが取得できる
    # (他の重要なカラムは取得できないようにする)
    # ストロングパラメータとは、RailsでDBを更新する際に、不要なパラメータを取り除く(必要なパラメータだけに絞り込む)ための仕組みです。
    # ストロングパラメータを使うことで、本来ユーザーから送られてくることのないパラメータが存在していたとしても、それを取り除いて安全にDBの更新を行うことができます。
    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end
    
end
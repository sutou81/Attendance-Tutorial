class User < ApplicationRecord
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
  before_save { self.email = email.downcase }

  validates :name,  presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true    
  # ↓ allow_nilとallow_blankの違い(https://pikawaka.com/rails/validation 参照)
  # allow_nil:値がnilの場合、検証を行わなくすることができます。
  # allow_blank:nilや空文字など値がblank?に該当する場合、検証を行わなくすることができます。
  # 2つの違い:allow_nilと似ていますが、allow_nilは空文字を入力した場合（フォームに何も入力しなかった場合）は検証をしてしまいますが、allow_blankだと検証をスキップさせることができます
  # *テキストでの説明:この設定では、値が空文字""の場合バリデーションをスルーします
  # *上記の追加説明:これは存在性の検証を入れていないことから、空の状態で送信し、2文字上の検証に引っかからないようにするために追加しました。
  validates :department, length: { in: 2..30 }, allow_blank: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil:true

  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  #↓update_attributeメソッドを使ってトークンダイジェストを更新しています。
  # update_attributes(勤怠第4章モデルを学ぼう4.3.3参照)と違い（よく見ると末尾にsがあるかないかの違いがあります）、こちらはバリデーションを素通りさせます。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end
end


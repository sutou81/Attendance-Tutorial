module UsersHelper
  
  # 勤怠基本情報を指定のフォーマットで返します。
  # ↓テキスト勤怠9章9.2.1の説明を見る
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end
    
end

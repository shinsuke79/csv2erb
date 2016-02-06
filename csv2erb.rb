require 'pp'
require 'csv'
require 'erb'

# 引数の変換
param_csv    = ARGV[0]
param_erb    = ARGV[1]
param_output = ARGV[2]
puts "## Start Csv2Erb csv:#{param_csv} erb:#{param_erb} file:#{param_output}"

# データベースの読み込み
abort "## ERROR #{param_csv} not found" unless File.exists?(param_csv)
puts "## Load csv..."
csv_row_list = CSV.table(param_csv)
csv_row_list.each do |row|
  print "## "
  pp row
end

# 読み込んだデータをERBを使用して書き出す
abort "## ERROR #{param_erb} not found" unless File.exists?(param_erb)
file = File.open(param_output, "w") if param_output

# ERB内で使用する変数
rows  = csv_row_list
first = true
last  = false
size  = rows.size

csv_row_list.each_with_index do |row, i|
  # 変数を更新
  first = (i == 0)
  last  = (i == size-1)

  erb_output = ERB.new(File.read(param_erb), nil, '-').result(binding)
  # fileがOpenされていれば書き込み、なければ端末出力
  if file
    file.write(erb_output)
  else
    print erb_output
  end
end
file.close if file

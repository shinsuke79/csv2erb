require 'pp'
require 'csv'
require 'erb'

class Csv2Erb
  attr_accessor :csv, :erb, :output_file
  attr_accessor :rows
  attr_accessor :first, :last, :size

  def initialize(csv, erb)
    raise "csv #{csv} is nil" unless csv
    raise "erb #{erb} is nil" unless erb
    @csv = csv
    @erb = erb
  end

  def execute(output_file=nil)
    @output_file = output_file

    # データベースの読み込み
    abort "## ERROR #{@csv} not found" unless File.exists?(@csv)
    puts "## Load csv..."
    @rows = CSV.table(@csv)
    @rows.each do |row|
      print "## "
      pp row
    end

    # 読み込んだデータをERBを使用して書き出す
    raise "## ERROR #{@erb} not found" unless File.exists?(@erb)

    # ファイル指定があるかどうかで切り分け
    if output_file
      file_write()
    else
      console_out()
    end
  end

  def console_out
    init_erb_param()
    rows_loop {|erb_output| print erb_output }
  end

  def file_write
    file = File.open(@output_file, "w")
    init_erb_param()
    rows_loop {|erb_output| file.write(erb_output) }
    file.close if file
  end

  # ERB内で使用する変数を初期化
  def init_erb_param
    @first = true
    @last  = false
    @size  = @rows.size
  end

  def rows_loop
    @rows.each_with_index do |row, i|
      # 変数を更新
      @first = (i == 0)
      @last  = (i == size-1)

      erb_output = ERB.new(File.read(@erb), nil, '-').result(binding)

      # fileがOpenされていれば書き込み、なければ端末出力
      yield(erb_output)
    end
  end
end

# 引数の変換
param_csv    = ARGV[0]
param_erb    = ARGV[1]
param_output = ARGV[2]
puts "## Start Csv2Erb csv:#{param_csv} erb:#{param_erb} file:#{param_output}"
Csv2Erb.new(param_csv, param_erb).execute(param_output)

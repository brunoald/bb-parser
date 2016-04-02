require 'pry'
require 'csv'
require 'byebug'

class Parser

  DATA_PATH = 'data/*.csv'

  def initialize
    @entries = []
  end

  def convert_date(date)
    parts = date.split('/')
    "#{parts[1]}/#{parts[0]}/#{parts[2]}"
  end

  def lines(file)
    lines = []
    open(file).each_line { |l| lines << fix_encoding(l) }
    2.times { lines.shift }
    lines.pop
    lines
  end

  def fix_encoding(line)
    line.force_encoding('iso-8859-1').encode('utf-8')
  end

  def extract_data(line)
    parts = line.gsub('"','').split(",")
    type = parts[2].split('-').first.strip
    place = parts[2].split('-').last.strip
    value = parts[5].to_s.gsub('.',',')
    entry_date = convert_date(parts[0])
    place = place.gsub(/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2}/,'').to_s.strip
    place = '' if type == place
    {
      entry_date: entry_date,
      type: type,
      place: place,
      value: value
    }
  end

  def run
    Dir.glob(DATA_PATH) do |file|
      lines(file).each do |line|
        @entries << extract_data(line)
      end
    end
    generate_csv
  end

  def generate_csv
    column_names = @entries.first.keys
    s = CSV.generate do |csv|
      csv << column_names
      @entries.each do |x|
        csv << x.values
      end
    end
    File.write('output.csv', s)
  end
end

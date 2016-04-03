require 'pry'
require 'csv'
require 'byebug'
require 'utils'
require 'yaml'

# This class parses CSV files
class Parser
  DATA_PATH = 'data/*.csv'.freeze
  DATETIME_REGEX = %r([0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2})

  def initialize
    @entries = []
  end

  def lines(file)
    lines = []
    open(file).each_line { |l| lines << Utils.fix_encoding(l) }
    2.times { lines.shift }
    lines.pop
    lines
  end

  def extract_entry_date(parts)
    Utils.convert_date(parts[0])
  end

  def extract_description(parts)
    parts[2].split('-')
  end

  def extract_type(parts)
    extract_description(parts).first.strip
  end

  def extract_place(parts)
    place = extract_description(parts).last.gsub(DATETIME_REGEX, '').to_s.strip
    place = '' if extract_type(parts) == place
    place
  end

  def extract_hour(parts)
    str = extract_description(parts).last
    str.match(DATETIME_REGEX).to_s.split(' ')[1]
  end

  def extract_period(hour)
    return nil if hour.nil?
    hh = hour.split(':').first.to_i
    return 'Madrugada' if (0..5).cover? hh
    return 'Manhã' if (6..11).cover? hh
    return 'Tarde' if (12..17).cover? hh
    'Noite'
  end

  def extract_value(parts)
    parts[5].tr('.', ',')
  end

  def extract_month(parts)
    date = extract_entry_date(parts)
    date.split('/')[1].to_i
  end

  def extract_year(parts)
    date = extract_entry_date(parts)
    date.split('/')[2].to_i
  end

  def extract_data(line)
    parts = line.delete('"').split(',')
    { entry_date: extract_entry_date(parts),
      month: extract_month(parts),
      year: extract_year(parts),
      type: extract_type(parts),
      place: extract_place(parts),
      value: extract_value(parts),
      hour: extract_hour(parts),
      period: extract_period(extract_hour(parts)),
      category: find_category(extract_place(parts)) }
  end

  def find_category(name)
    categories = YAML.load_file('config/categories.yml')
    categories.each do |list|
      list.each do |k, terms|
        terms.each do |term|
          return k if name =~ /#{term}\s|#{term}$/
        end
      end
    end
    'Indefinido'
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

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
    hour = extract_hour(place)
    value = parts[5].to_s.gsub('.',',')
    entry_date = convert_date(parts[0])
    place = place.gsub(/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2}/,'').to_s.strip
    place = '' if type == place
    period = extract_period(hour)
    {
      entry_date: entry_date,
      month: entry_date.split('/')[1].to_i,
      year: entry_date.split('/')[2].to_i,
      type: type,
      place: place,
      value: value,
      hour: hour,
      period: period,
      category: category(place)
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

  def extract_hour(str)
    str.match(/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2}/).to_s.split(' ')[1]
  end

  def extract_period(hour)
    return nil if hour.nil?
    hh = hour.split(':')[0].to_i
    if hh >= 0 && hh <= 5
      'Madrugada'
    elsif hh >= 6 && hh <= 11
      'Manhã'
    elsif hh >= 12 && hh <= 17
      'Tarde'
    else
      'Noite'
    end
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

  def category(name)
    list = {
      "Combustível" => [
        "POSTO",
        "COMBUSTIVEIS",
      ],
      "Supermercado" => [
        "CARREFOUR",
        "EXTRA",
        "VERDE MAR" ,
        "VERDEMAR",
        "EPA",
        "SUPERNOSSO",
        "SUPER NOSSO",
      ],
      "Comida" => [
        "LANCHES?",
        "LANCHONETE",
        "RESTAURANTE",
        "TRIGOPANE",
        "PADARIA",
        "MERCADO",
        "CANTINA",
        "EMPORIO",
        "DOCES",
        "FRANGO",
        "CARNE",
        "GRAAL",
        "REST",
        "FRUTAS",
        "TRAILER",
        "PARRILLA",
        "RESTAU",
        "BISCOITOS?",
        "MATE",
        "SPOLETO",
      ],
      "Farmácia" => [
        "DROGARIA",
        "DROGA"
      ],
      "Lazer" => [
        "HABIBBS",
        "CHURRASCARIA",
        "PIZZA",
        "GOURMET",
        "BURGER",
        "BAR",
        "BOI",
        "CAFE",
        "CAFETERIA",
        "BISTRO",
        "KOPENHAGEN",
        "CINEMARK",
        "CINEART",
        "CINEPLEX",
        "ESPETINHO",
        "CHOPP",
        "OUTBACK",
        "PUB",
        "CHURRASCO",
        "CHOPPERIA",
        "CHOPERIA",
      ]
    }
    list.each do |k, terms|
      terms.each do |term|
        if name.match(/#{term}\s|#{term}$/)
          return k
        end
      end
    end
    "Indefinido"
  end
end

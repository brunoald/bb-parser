# This class provides some helper methods
class Utils
  def self.convert_date(date)
    parts = date.split('/')
    "#{parts[1]}/#{parts[0]}/#{parts[2]}"
  end

  def self.fix_encoding(line)
    line.force_encoding('iso-8859-1').encode('utf-8')
  end
end

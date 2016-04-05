require 'spec_helper'
require_relative '../lib/parser'

describe Parser do
  let(:parser) { Parser.new }
  let(:lines) { parser.lines(fixture_path('example.csv')) }

  context 'reading files' do
    context 'when file exists' do
      it 'rejects useless lines' do
        expect(lines[0]).to match('POSTO GRAJAU')
      end
    end

    context 'when file does not exist' do
      it do
        expect do
          parser.lines('non-existent.csv')
        end.to raise_error(Errno::ENOENT)
      end
    end
  end

  context 'data extraction' do
    let(:data) { parser.extract_data(lines[0]) }
    context 'when there is a place and time' do
      it { expect(data[:entry_date]).to eql('13/10/2015') }
      it { expect(data[:type]).to eql('Compra com Cartão') }
      it { expect(data[:place]).to eql('POSTO GRAJAU') }
      it { expect(data[:category]).to eql('Combustível') }
      it { expect(data[:value]).to eql('-40,00') }
      it { expect(data[:hour]).to eql('16:16') }
      it { expect(data[:period]).to eql('Tarde') }
      it { expect(data[:month]).to eql(10) }
      it { expect(data[:year]).to eql(2015) }
    end

    context 'when there is no place"' do
      let(:lines) { parser.lines(fixture_path('example_noplace.csv')) }
      it { expect(data[:entry_date]).to eql('25/09/2015') }
      it { expect(data[:type]).to eql('Estorno de Débito') }
      it { expect(data[:place]).to eql('') }
      it { expect(data[:value]).to eql('6,90') }
    end
  end

  context 'category discovery' do
    it { expect(parser.find_category('POSTO GRAJAU')).to eql('Combustível') }
    it { expect(parser.find_category('DROGARIA ARAUJO')).to eql('Farmácia') }
    it { expect(parser.find_category('DROGARIA RAIA')).to eql('Farmácia') }
    it { expect(parser.find_category('BARRACA')).to eql('Indefinido') }
    it { expect(parser.find_category('BAR')).to eql('Lazer') }
    it { expect(parser.find_category('BAR DO JOAO')).to eql('Lazer') }
  end

  context 'period extraction' do
    it { expect(parser.extract_period('00:00')).to eql('Madrugada') }
    it { expect(parser.extract_period('06:00')).to eql('Manhã') }
    it { expect(parser.extract_period('12:00')).to eql('Tarde') }
    it { expect(parser.extract_period('18:00')).to eql('Noite') }
  end

  context 'CSV generation' do
    let(:parser) { Parser.new({ data_path: 'spec/fixtures/run' }) }
    let(:csv) do
      [
       "entry_date,month,year,type,place,value,hour,period,category",
       "13/10/2015,10,2015,Compra com Cartão,POSTO GRAJAU,\"-40,00\",16:16,Tarde,Combustível\n"
      ].join("\n")
    end
    before do
      allow(File).to receive(:write)
      parser.run
    end
    it { expect(File).to have_received(:write).with('output.csv', csv) }
  end
end

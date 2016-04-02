require 'spec_helper'
require_relative '../lib/parser'

describe Parser do
  let(:parser) { Parser.new }
  let(:lines) { parser.lines(fixture_path('example.csv')) }

  context 'reading files' do
    context 'when file exists' do
      it 'rejects useless lines' do
        expect(lines.size).to eql 1
        expect(lines[0]).to match("POSTO GRAJAU")
      end
    end

    context 'when file does not exist' do
      it { expect { parser.lines('non-existent.csv') }.to raise_error(Errno::ENOENT) }
    end
  end

  context 'date conversion' do
    it { expect(parser.convert_date('10/20/2015')).to eql('20/10/2015') }
  end

  context 'data extraction' do
    let(:data) { parser.extract_data(lines[0]) }
    context 'when there is a place and time' do
      it { expect(data[:entry_date]).to eql('13/10/2015') }
      it { expect(data[:type]).to eql('Compra com Cartão') }
      it { expect(data[:place]).to eql('POSTO GRAJAU') }
      it { expect(data[:value]).to eql('-40,00') }
    end

    context 'when there is no place"' do
      let(:lines) { parser.lines(fixture_path('example_noplace.csv')) }
      it { expect(data[:entry_date]).to eql('25/09/2015') }
      it { expect(data[:type]).to eql('Estorno de Débito') }
      it { expect(data[:place]).to eql('') }
      it { expect(data[:value]).to eql('6,90') }
    end
  end
end

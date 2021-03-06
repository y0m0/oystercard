require 'oystercard'

RSpec.describe Oystercard do
  subject(:card) { Oystercard.new }

  let(:entry_station) { double(:station) }
  let(:exit_station) { double(:station) }

  it 'have a starting default balance of zero.' do
    expect(card.balance).to eq 0
  end

  describe '#top_up' do
    it 'can top up the balance with desired amount' do
      expect { card.top_up(1) }.to change { card.balance }.to 1
    end

    it 'raises an error if the maximum balance is exceeded' do
      card.top_up(Oystercard::BALANCE_LIMIT)
      expect { card.top_up(1) }.to raise_error "Maximum balance of £#{Oystercard::BALANCE_LIMIT} exceeded"
    end
  end

  describe '#touch_in' do
    let(:station) { double(:station) }

    it "raise error if balance is below £#{Oystercard::MINIMUM_FARE}" do
      expect { card.touch_in(station) }.to raise_error 'Balance below minimum.'
    end
  end

  describe '#touch_out' do

    it "deducts #{Oystercard::MINIMUM_FARE} from balance" do
      card.top_up(Oystercard::MINIMUM_FARE)
      expect { card.touch_out(exit_station) }.to change { card.balance }.by(-Oystercard::MINIMUM_FARE)
    end
  end

  describe '#retrieve_journey_history' do

    it 'returns a list for one journey' do
      card.top_up(Oystercard::MINIMUM_FARE)
      card.touch_in(entry_station)
      card.touch_out(exit_station)
      expect(card.retrieve_journey_history).to eq [{ entry: entry_station, exit: exit_station }]
    end
  end

  describe '#fare' do
    before(:each) { card.top_up(Oystercard::MINIMUM_FARE) }

    it 'know the minimum fare' do
      card.touch_in(entry_station)
      card.touch_out(exit_station)
      expect(card.fare).to eq Oystercard::MINIMUM_FARE
    end

    it 'knows when an entry station is not present' do
      expect(card.fare).to eq Oystercard::PENALTY_FARE
    end

    it 'knows when an exit station is not present' do
      card.touch_in(entry_station)
      expect(card.fare).to eq Oystercard::PENALTY_FARE
    end

  end
end

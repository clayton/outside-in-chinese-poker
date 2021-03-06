require 'spec_helper'
require 'ostruct'

describe "Hand Categorization" do
  FakeHandOrganizer = Struct.new(:to_s) do
    def organize(hand)
      return ""
    end
  end

  FakeOrganizedHand = Struct.new(
    :two_cards_match?,
    :two_different_cards_match?,
    :three_cards_match?,
    :four_cards_match?,
    :all_suits_match?,
    :ranks_in_order?,
    :high_card_ace?,
    :three_card_hand?
  )

  before(:each) do
    @organizer = FakeHandOrganizer.new
    @sut = OfcpScoring::HandCategorizer.new(@organizer)
  end

  context "Five Card Hands" do
    it "should return an empty string if no hand is present" do
      expect(@sut.categorize(nil)).to eq("")
    end
    it "should return a Pair when two cards match" do
      hand = FakeOrganizedHand.new(:two_cards_match)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::Pair.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
    it "should return two Pair when two sets of two cards match" do
      hand = FakeOrganizedHand.new(:two_cards_match, :two_different_cards_match)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::TwoPair.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
    it "should return Three Of a Kind when three cards match" do
      hand = FakeOrganizedHand.new(false, false, :three_cards_match)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::ThreeOfAKind.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
    it "should return Four of a kind when four cards match" do
      hand = FakeOrganizedHand.new(false, false, false, :four_cards_match)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::FourOfAKind.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
    it "should return Full House when three cards match and two cards match" do
      hand = FakeOrganizedHand.new(:two_cards_match, false, :three_cards_match)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::FullHouse.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
    it "should return High Card when no cards match" do
      hand = FakeOrganizedHand.new(false, false, false, false)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::HighCard.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
    it "should return OfcpScoring::Flush when suits all same" do
      hand = FakeOrganizedHand.new(false, false, false, false, :all_suits_match)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::Flush.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
    it "should return Straight when all five cards are in sequential order" do
      hand = FakeOrganizedHand.new(false, false, false, false, false, :ranks_in_order)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::Straight.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
    it "should return a StraightFlush when all five cards are in sequential order and all suits match" do
      hand = FakeOrganizedHand.new(false, false, false, false, :all_suits_match, :ranks_in_order)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::StraightFlush.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
    it "should return a RoyalFlush when all five cards are in sequential order, all suits match and highest rank is an Ace" do
      hand = FakeOrganizedHand.new(false, false, false, false, :all_suits_match, :ranks_in_order, :high_card_ace)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::RoyalFlush.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
  end
  context "Three Card Hands" do
    it "should never return a flush" do
      hand = FakeOrganizedHand.new(false, false, false, false, :all_suits_match, :ranks_in_order, :high_card_ace, :three_card_hand)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::HighCard.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
    it "should never return a straight" do
      hand = FakeOrganizedHand.new(false, false, false, false, false, :ranks_in_order, :high_card_ace, :three_card_hand)
      @organizer.stub(:organize).and_return(hand)
      OfcpScoring::HighCard.should_receive(:new).with(hand)
      @sut.categorize(hand)
    end
  end

end


describe "Integration" do
  it "should categorized unorganized hands correctly" do
    sut = OfcpScoring::HandCategorizer.new
    # expect(sut.categorize(%w(Ah 4s Qs))).to be_a(OfcpScoring::HighCard)
    # expect(sut.categorize(%w(2h 3h 4h 5h 7h))).to be_a(OfcpScoring::Flush)
    expect(sut.categorize(%w(Kh Kd Ks 9c 9s))).to be_a(OfcpScoring::FullHouse)
  end
end

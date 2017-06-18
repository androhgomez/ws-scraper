require "mechanize"
require "pry"

class CardLinkScraper

  def initialize(params)
    @agent = Mechanize.new
    @expansion_id = params[:expansion_id]
  end

  def card_numbers
    @card_numbers ||= get_card_numbers
  end

  private

  def get_number_of_cards(page)
    pagelink_text = page.search(".pageLink").first.children.first.text
    pagelink_text[/([0-9]*)\]$/, 1].to_i
  end

  def get_card_numbers
    current_page = 1
    links = []
    page = @agent.post('http://ws-tcg.com/en/jsp/cardlist/expansionDetail', {expansion_id: @expansion_id, page: current_page})
    number_of_cards = get_number_of_cards(page)
    begin
      page = @agent.post('http://ws-tcg.com/en/jsp/cardlist/expansionDetail', {expansion_id: @expansion_id, page: current_page})
      @agent.page.links.each { |l| links << l.href.gsub("?cardno=", "") if l.href.include?("cardno") }
      current_page += 1
    end until links.count == number_of_cards
    links
  end

end


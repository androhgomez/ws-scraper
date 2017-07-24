require "mechanize"

class ExpansionIdScraper
  DEFAULT_EXPANSION_URL = 'http://ws-tcg.com/en/jsp/cardlist/'
  
  def initialize(params) 
    @agent = Mechanize.new
    @page = @agent.get(params[:expansion_url] || DEFAULT_EXPANSION_URL)
  end

  def expansion_ids
    @expansion_ids ||= get_expansion_ids
  end

  def get_expansion_ids
    ids = {}
    expansion_type_headers = @agent.page.css('#expansionList h3')
    expansion_type_headers.each do |exp|
      ids[exp.text] = get_ids_from_link_list(exp.css('~ ul').first)
    end
    ids
  end

  def get_ids_from_link_list(link_list)
    result = {}
    link_list.css('a').each { |l| result[l.text[/\r\n([^>]*)/,1]] = l.attributes["onclick"].value unless l.attributes["onclick"].nil? }
    result.each do |k, v|	    
      result[k] = trim_js(v)
    end
    result
  end

  def trim_js(text)
    text[/showExpansionDetail\('([^>]*)',''\); return false;/, 1]
  end
end

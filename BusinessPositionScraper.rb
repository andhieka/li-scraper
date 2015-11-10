require 'net/http'
require 'byebug'
require 'json'
require 'set'

class SkillScraper

  def initialize
    @skills = Set.new
    @filename = 'business_positions.json'
  end

  def load
    if File.exists? @filename
      File.open(@filename, 'r') do |f|
        text = f.read
        arr = JSON.parse text
        arr.map do |skill|
          @skills.add skill
        end
        puts "Loaded #{arr.count} skills..."
      end
    end
  end

  def save
    File.open(@filename, 'w') do |f|
      text = JSON.pretty_generate @skills.to_a
      f.write text
      puts "Saved #{@skills.count} skills..."
    end
  end

  def run
    self.load
    print "Enter business positions to scrape: "
    while line = gets
      skill_name = line.strip
      if skill_name == "save"
        self.save
      elsif skill_name == "exit"
        self.save
        break
      else
        skill_name
        params = { :query => skill_name }
        puts params
        uri = URI('https://www.linkedin.com/ta/titleV2')
        uri.query = URI.encode_www_form(params)
        puts "Querying #{uri}"
        res = Net::HTTP.get_response(uri)
        res_json = JSON.parse(res.body)
        skills = res_json['resultList']
        skill_names = skills.map { |skill| skill['displayName'] }
        puts skill_names
        skill_names.map { |s| @skills.add s }
        self.save
      end
      print "Enter business positions to scrape: "
    end
  end
end

s = SkillScraper.new
s.run

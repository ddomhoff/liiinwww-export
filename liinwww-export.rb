#!/usr/local/bin/ruby

#
# BibTex export for the The Collection of Computer Science Bibliographies (https://liinwww.ira.uka.de/bibliography/)
#
# https://github.com/ddomhoff/liinwww-export/
#
# Runs search query in database and outputs single file with all BibTex records.
# If number of results exceeds 1,000 queries are run separately for each publication year to avoid the limitation per query.
#
# Usage:
# ./liinwww-export.rb "+search +string" 
# saves results to csbout.bib
#
# ./liinwww-export.rb "+search +string" outfile.bib
# saves results to outfile.bib
#

require 'uri'
require 'nokogiri'
require 'open-uri'

class CSBExport
  def initialize(query)
    @maxnum = 200
    @query = query
    @hits = getHits
    if @hits == 0
      STDERR.puts "No results for search query"
      exit
    end
  end

  def hits
    return @hits
  end

  def results
    if hits <= 1000
      return getResults
    else
      print "Query yields > 1000 results, fetching yearly"
      return getYearlyResults
    end
  end

  private

  def getHits(query=@query)
    n_results = /Returned:.*?(\d+|No|One) (matching )?[dD]ocument(s)?/.match(getPage(1, query).text.encode('UTF-8', 'UTF-8', :invalid => :replace))[1]
    return n_results.gsub("One", "1").gsub("No", "0").to_i
  end

  def getPage(start=1, query=@query, maxnum=@maxnum)
    url = "http://liinwww.ira.uka.de/csbib?sort=year&results=bibtex&start=#{start}&maxnum=#{maxnum}&query="
    return Nokogiri::HTML(open(url+URI.escape(query).gsub('+', '%2B')))
  end

  def getResults(query=@query)
    maxnum = @maxnum
    start = 1
    r = String.new
    loop do
      r << getPage(start, query, maxnum).css('pre.bibtex').text
      print "Fetching #{start} to max. #{start+maxnum} of #{@hits}"

      start = start + maxnum + 1
      
      if start + maxnum > 1000
        maxnum = 1000 - start + 1
      end
      
      if start >= @hits || start >= 1000
        break
      end
    end
    return r
  end

  def getYearlyResults
    years = ['[0000 TO 1980]', (1981..Time.new.year-1).to_a, "[#{Time.new.year} TO 2100]"].flatten.map{|y| "yr:#{y}"}
    start = 1
    r = String.new
    years.each do |y|
      print y
      q = "+(#{@query}) +#{y}"
      @hits = getHits(q)
      if @hits > 1000
        STDERR.puts "Notice: Results for #{y} exceed 1000 results. Only fetching first 1000."
      end
      r << getResults(q)
    end
    return r
  end
end


if ARGV.empty?
  STDERR.puts "Error: No arguments specified"
  exit
end

csb = CSBExport.new(ARGV[0])
File.write(ARGV.length == 1 ? 'csbout.bib' : ARGV[1], csb.results)

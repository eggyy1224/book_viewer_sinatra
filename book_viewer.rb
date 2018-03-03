require "sinatra"
require "sinatra/reloader"
require 'pry'
require "tilt/erubis"

before do
  @contents = File.readlines('data/toc.txt')
end

get "/" do
  @title = 'HOME'
  # binding.pry
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  redirect "/" unless (1..@contents.size).cover? number
  @title = "Chapter #{number}: #{@contents[number - 1]}"
  @chapter = File.readlines("data/chp#{params[:number]}.txt", "\n\n")
  # binding.pry
  erb :chapter
end



def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

not_found do
  redirect '/'
end

helpers do
  def in_paragraphs(para_arr)
    para_arr.map.with_index do |paragraph, index|
      "<p id=paragraph#{index}>#{paragraph}</p>"
    end.join
  end

  def emphasize_result(text, query)
    text.gsub(/(#{query})/, '<strong>\1</strong>' )
  end
end
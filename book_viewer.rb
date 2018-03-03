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
    results << {number: number, name: name} if contents.include?(query)
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
    para_arr.map do |paragraph|
      "<p>#{paragraph}</p>"
    end.join
  end
end
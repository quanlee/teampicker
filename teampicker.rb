require "sinatra"
require "sinatra/reloader"
require "pry"

enable :sessions
get "/" do
  redirect "/teampicker"
end

get "/teampicker" do
  if session[:tp_names]
    @tp_names = session[:tp_names]
    @tp_number = session[:tp_number]
    @tp_method = session[:tp_method]
  else
    @tp_names = ""
    @tp_number = "2"
    @tp_method = "N"
  end
  @tp_everyone_array = @tp_names.split(",")
  @tp_everyone_array.each {|name| name.strip!}
  @tp_checked_people = @tp_everyone_array.map {|name| name.sub(" ", "_")}
  @tp_result = []
  erb :teampicker, layout: :master
end

def assign_by_per_team
  people_count = @tp_people_to_assign.length
  while people_count > 0
    team_count = 0
    newteam = []
    while team_count < @tp_number.to_i && people_count > 0
      random_number = rand(people_count)
      name = @tp_people_to_assign.slice!(random_number)
      newteam.push name
      people_count = @tp_people_to_assign.length
      team_count += 1
    end
    @tp_result.push newteam
  end
end

def assign_by_team_number
  people_count = @tp_people_to_assign.length
  for teamIx in 0..(@tp_number.to_i - 1)
    newteam = []
    @tp_result.push newteam
  end
  while people_count > 0
    team_index = 0
    while team_index < @tp_number.to_i && people_count > 0
      random_number = rand(people_count)
      name = @tp_people_to_assign.slice!(random_number)
      @tp_result[team_index].push name
      people_count = @tp_people_to_assign.length
      team_index += 1
    end
  end
end

post "/teampicker" do
  @tp_names = params[:tp_names]
  @tp_method = params[:tp_method]
  if params[:tp_number].to_i == 0 || !(params[:tp_number].to_i.is_a? Integer)
    @tp_number = session[:tp_number]
  else
    @tp_number = params[:tp_number]
  end

  @tp_everyone_array = @tp_names.split(",").map {|name| name.strip}
  @tp_checked_people = []
  @tp_people_to_assign = []
  @tp_everyone_array.each do |name|
    name_with_underscore = name.sub(" ", "_")
    if params[name_with_underscore] == "checked" || !session[:tp_names].include?(name)
      @tp_checked_people.push name_with_underscore
      @tp_people_to_assign.push name
    end
  end

  @tp_result = []
  if @tp_method == "N"
    assign_by_per_team
  elsif @tp_method == "T"
    assign_by_team_number
  end

  session[:tp_names] = @tp_names
  session[:tp_number] = @tp_number
  session[:tp_method] = @tp_method

  erb :teampicker, layout: :master
end

require 'octokit'
require 'json'
class GitHubReposAnalyser

  def initialize
    @user_name = ""
  end

  def get_favourite_language_by_user(user_name)
    @user_name = user_name
    Octokit.auto_paginate = true
    languages = favourite_languages(Octokit.repositories(@user_name))
    format languages   
  end

  private
    
  def language_counts(repos)
    repos.inject(Hash.new(0)) do |hsh, repo|
      hsh[repo.language] += 1 if repo.language
      hsh
    end
  end

  def favourite_languages(repos)
    counts = language_counts(repos)
    max_count = counts.values.max
    counts.select{|k,v| v == max_count}.keys
  end

  def format(favourites)
    return "#{@user_name} has no favourite programming language defined\." if favourites.empty?
    
    favourites.size == 1 ?
      "#{favourites.first} is the favourite programming language of user #{@user_name}" :
      "#{favourites.join(',')} are the favourite programming languages of user #{@user_name}" 
  end
end

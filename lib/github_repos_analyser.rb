require 'restclient'
require 'json'
class GitHubReposAnalyser

  def initializer
    @user_name = ""
  end

  def get_favourite_language_by_user(user_name)
    @user_name = user_name
    json = repos_to_json
    counts = json_to_language_counts json
    languages = favourites counts
    format languages
  end

  private

    def repos_to_json
      url = "https://api.github.com/users/#{@user_name}/repos"
      JSON.parse RestClient.get(url,{accept: 'application/vnd.github.beta+json'})
    end
    
    def json_to_language_counts(json)
      language_counts = json.inject(Hash.new(0)) do |hsh, repo|
        repo['language'].nil? || hsh[repo['language']] += 1
        hsh
      end
    end

    def favourites(language_counts)
      language_counts.select {|k,v| v == language_counts.values.max}.keys
    end

    def format(favourites)
      return "#{@user_name} has no favourite programming language defined\." if favourites.empty?
      
      favourites.one? ?
        "#{favourites.first} is the favourite programming language of user #{@user_name}" :
        "#{favourites.join(',')} are the favourite programming languages of user #{@user_name}" 
    end
end

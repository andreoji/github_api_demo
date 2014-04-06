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
    format_language_counts counts
  end
  private
    def repos_to_json
      url = "https://api.github.com/users/#{@user_name}/repos"
      response = RestClient.get(url,{accept: 'application/vnd.github.beta+json'})
      json = JSON.parse(response)
    end

    def json_to_language_counts(json)
      language_counts = Hash.new(0)
      json.each do |repo| 
        if (!repo['language'].nil? and !language_counts.key? repo['language'])
          language_counts[repo['language']] = 1
        elsif (!repo['language'].nil? and language_counts.key? repo['language'])
          language_counts[repo['language']] += 1
        end
      end
      language_counts
    end

    def format_language_counts(language_counts)
      return "#{@user_name} has no favourite programming language defined\." if language_counts.empty?
      language = language_counts.select {|k,v| v == language_counts.values.max}.keys.join(',')
      language.include?(',') ? "#{language} are the favourite programming languages of user #{@user_name}" : 
      "#{language} is the favourite programming language of user #{@user_name}"
    end
end

require 'webmock/rspec'
require 'github_repos_analyser'
include WebMock::API

describe GitHubReposAnalyser do
  let (:repos_analyser) { GitHubReposAnalyser.new}
  let (:valid_user_name) {"steveklabnik"}
  let (:headers) {
    { 
      'Accept'          => 'application/vnd.github.beta+json',
      'Accept-Encoding' => 'gzip, deflate', 
      'User-Agent'      => 'Ruby'
    }
  }
  
  def uri_of_users_repos(user_name)
    "https://api.github.com/users/#{user_name}/repos"
  end
  
  context 'given steveklabnik with 3 Ruby, 1 JavaScript and 1 Shell repos' do
    let (:response_body) {
      "[{\"language\":\"Ruby\"},
        {\"language\":\"Ruby\"},
        {\"language\":\"Ruby\"},
        {\"language\":\"JavaScript\"},
        {\"language\":\"Shell\"}]"
    }
    before do
      stub_request(:get, uri_of_users_repos("steveklabnik"))
        .with(headers: headers)
        .to_return(status: 200, body: response_body)
    end
    it 'should make a GET to the GitHub api' do
      repos_analyser.get_favourite_language_by_user(valid_user_name)
      WebMock
        .should have_requested(:get, uri_of_users_repos(valid_user_name))
        .with(headers: headers)
    end
    it 'should find Steves favourite language to be Ruby' do
      repos_analyser
        .get_favourite_language_by_user(valid_user_name)
        .should == "Ruby is the favourite programming language of user steveklabnik"
    end
  end

  context 'given steveklabnik with 3 Ruby, 3 JavaScript and 1 Shell repos' do
    let (:response_body) {
      "[{\"language\":\"Ruby\"},
        {\"language\":\"Ruby\"},
        {\"language\":\"Ruby\"},
        {\"language\":\"JavaScript\"},
        {\"language\":\"JavaScript\"},
        {\"language\":\"JavaScript\"},
        {\"language\":\"Shell\"}]"
    }
    before do
      stub_request(:get, uri_of_users_repos("steveklabnik"))
        .with(headers: headers)
        .to_return(status: 200, body: response_body)
    end
    it 'should find Steves favourite languages to be Ruby,JavaScript' do
      repos_analyser
        .get_favourite_language_by_user(valid_user_name)
        .should == "Ruby,JavaScript are the favourite programming languages of user steveklabnik"
    end
  end

  context 'given shell_user with 3 null language, 2 Shell and 1 Ruby repos' do
    shell_user = "shell_user"
    let (:response_body) {
      "[{\"language\":\"Shell\"},
        {\"language\":null},
        {\"language\":\"Shell\"},
        {\"language\":null},
        {\"language\":null},
        {\"language\":\"Ruby\"}]"
    }
    before do
      stub_request(:get, uri_of_users_repos(shell_user))
        .with(headers: headers)
        .to_return(status: 200, body: response_body)
    end
    it 'should find shell_users favourite language is Shell' do
      repos_analyser
        .get_favourite_language_by_user(shell_user)
        .should == "Shell is the favourite programming language of user shell_user"
    end
  end

  context 'given null_lanaguage_user with 6 null language repos' do
    null_language_user = "null_language_user"
    let (:response_body) {
      "[{\"language\":null},
        {\"language\":null},
        {\"language\":null},
        {\"language\":null},
        {\"language\":null},
        {\"language\":null}]"
    }
    before do
      stub_request(:get, uri_of_users_repos(null_language_user))
        .with(headers: headers)
        .to_return(status: 200, body: response_body)
    end
    it 'should find there is no favourite programming language' do
      repos_analyser
        .get_favourite_language_by_user(null_language_user)
        .should == "null_language_user has no favourite programming language defined."
    end
  end

  context 'given a user without any repos' do
    empty_user = "empty_user"
    let (:response_body) {"[]"}
    before do 
      stub_request(:get, uri_of_users_repos(empty_user))
        .with(headers: headers)
        .to_return(status:200, body: response_body)
    end
    it 'should find there is no favourite programming language' do
      repos_analyser
        .get_favourite_language_by_user("#{empty_user}")
        .should == "empty_user has no favourite programming language defined."
    end
  end

  context 'a user that does not exist' do
    it 'should raise a ResourceNotFound exception' do
      invalid_user_name = "stevexklabnik"
      stub_request(:get, "https://api.github.com/users/#{invalid_user_name}/repos")
        .to_raise(RestClient::ResourceNotFound)
      expect {
        repos_analyser
          .get_favourite_language_by_user(invalid_user_name)
      }.to raise_error(RestClient::ResourceNotFound)
      WebMock
        .should have_requested(:get, uri_of_users_repos(invalid_user_name))
        .with(headers: headers)      
    end
  end
end

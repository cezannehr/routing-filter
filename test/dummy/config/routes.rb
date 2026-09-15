TestRailsAdapter::Application.routes.draw do
  filter :uuid, :pagination ,:locale, :extension
  get "/" => "tests#index"
  get "/foo/:id" => "tests#show", :as => 'foo'

  # A mounted Rack app that echoes what it was handed, so tests can assert the
  # mount-relative SCRIPT_NAME / PATH_INFO survive the recognition filters.
  mount lambda { |env|
    [200, { "Content-Type" => "text/plain" }, ["#{env['SCRIPT_NAME']}|#{env['PATH_INFO']}"]]
  } => "/engine"
end

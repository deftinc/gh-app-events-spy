Rails.application.routes.draw do
  post '/webhooks/github' => 'github_webhooks#handle'
  root to: redirect { |path_params, req| "https://dashboard.heroku.com/apps/#{req.subdomain}" }
end

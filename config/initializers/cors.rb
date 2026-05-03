# Be sure to restart your server when you modify this file.

# Handle Cross-Origin Resource Sharing (CORS) to accept cross-origin requests.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Development: allow localhost requests
    origins "http://localhost:3000", "http://localhost:3001", "http://localhost:5173",
            "http://127.0.0.1:3000", "http://127.0.0.1:5173"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ],
      credentials: true
  end

  # Production: add your frontend domains here
  # allow do
  #   origins ENV.fetch("FRONTEND_URL", "https://your-production-domain.com")
  #
  #   resource "*",
  #     headers: :any,
  #     methods: [:get, :post, :put, :patch, :delete, :options, :head],
  #     credentials: true
  # end
end

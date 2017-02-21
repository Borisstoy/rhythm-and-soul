class CallToApiService

def authenticate
  @discogs     = Discogs::Wrapper.new("rhythm-and-soul")
  request_data = @discogs.get_request_token("rhythm-and-soul", "VtqMfRJTdxwexjoGfeuDDRLzsZpSDYRa", "http://localhost:3000/callback")

  session[:request_token] = request_data[:request_token]

  redirect_to request_data[:authorize_url]
end

# And an action that Discogs will redirect back to.
def callback
  @discogs      = Discogs::Wrapper.new("rhythm-and-soul")
  request_token = session[:request_token]
  verifier      = params[:oauth_verifier]
  access_token  = @discogs.authenticate(request_token, verifier)

  session[:request_token] = nil
  session[:access_token]  = access_token

  @discogs.access_token = access_token

  # You can now perform authenticated requests.
  results = wrapper.search("Nick Cave")
  puts results
end

# Once you have it, you can also pass your access_token into the constructor.
end

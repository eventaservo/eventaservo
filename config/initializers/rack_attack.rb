class Rack::Attack
  safelist('allow-localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  throttle('requets by IP', limit: 30, period: 5) do |req|
    req.ip
  end

  throttle('limit logins per email', limit: 3, period: 60) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.params['email']
    end
  end
end


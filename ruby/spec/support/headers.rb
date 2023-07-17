module HeaderType
  HTTP_AUTH = 1
  CONTENT_TYPE = 2
end

def auth_token(user: ENV['USERNAME'], password: ENV['PASSWORD'])
  Base64.encode64(user + ':' + password)
end

def generate_auth_headers(user: ENV['USERNAME'], password: ENV['PASSWORD'])
  { 'HTTP_AUTHORIZATION' => "Basic #{auth_token(user: user, password: password)}" }
end

def prepare_headers(type = nil)
  case type
  when HeaderType::HTTP_AUTH
    generate_auth_headers
  when HeaderType::CONTENT_TYPE
    { 'CONTENT_TYPE' => 'application/json' }
  else
    prepare_headers(HeaderType::HTTP_AUTH).merge(prepare_headers(HeaderType::CONTENT_TYPE))
  end
end

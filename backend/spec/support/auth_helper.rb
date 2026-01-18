module AuthHelper
  def auth_headers(user)
    payload = {
      sub: user.id,
      scp: "user",
      aud: nil,
      iat: Time.now.to_i,
      exp: 24.hours.from_now.to_i,
      jti: SecureRandom.uuid
    }
    token = JWT.encode(payload, Rails.application.secret_key_base, 'HS256')

    {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    }
  end
end

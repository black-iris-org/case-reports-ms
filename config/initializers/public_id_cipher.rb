if ENV["PUBLIC_ID_CIPHER_KEY"].to_s.length < 32
  raise "PUBLIC_ID_CIPHER_KEY must be set and at least 32 characters"
end

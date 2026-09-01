# frozen_string_literal: true

module SixDigitCipherHelper
  module_function

  RADIX = 1000 # each half is 0..999
  DOMAIN = RADIX * RADIX # exactly 1,000,000 — no dead zone
  ROUNDS = 4

  def scramble(n)
    left  = n / RADIX
    right = n % RADIX
    ROUNDS.times { |i| left, right = right, (left + f(right, i)) % RADIX }
    left * RADIX + right
  end

  def f(right, round)
    d = OpenSSL::HMAC.digest("SHA256", key, "#{round}:#{right}")
    d.unpack1("N") % RADIX
  end

  def key
    ENV.fetch("PUBLIC_ID_CIPHER_KEY") # raises KeyError at use if unset
  end
end

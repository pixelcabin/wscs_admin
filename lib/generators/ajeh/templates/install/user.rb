  has_secure_password

  attr_accessor :remember_me

  def gravatar_image
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    default_url = URI.encode('https://dl.dropboxusercontent.com/u/2440044/default_user_avatar.png')
    "http://www.gravatar.com/avatar/#{hash}?d=#{default_url}"
  end

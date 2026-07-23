class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy


  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
              format: { with: URI::MailTo::EMAIL_REGEXP },
              uniqueness: true

  validates :full_name, presence: true

  validates :password, length: { minimum: 8 }, allow_nil: true

  def self.from_omniauth(auth)
    provider = auth.provider
    uid      = auth.uid
    email    = auth.info.email

    user = find_by(provider: provider, uid: uid)
    return user if user

    return nil unless email.present? && email_verified?(auth)

    user = find_or_initialize_by(email_address: email) do |u|
      u.password = SecureRandom.hex(15)
    end

    user.provider  = provider
    user.uid       = uid
    user.full_name = auth.info.name if user.full_name.blank?
    user.save!
    user
  end

  def self.email_verified?(auth)
    verified = auth.info&.email_verified
    verified = auth.extra&.raw_info&.email_verified if verified.nil?
    ActiveModel::Type::Boolean.new.cast(verified) == true
  end
  private_class_method :email_verified?

  generates_token_for :confirmation, expires_in: 1.day do
    email_address
  end

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update!(confirmed_at: Time.current)
  end
end

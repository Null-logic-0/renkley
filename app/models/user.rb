class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy


  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true,
              format: { with: URI::MailTo::EMAIL_REGEXP },
              uniqueness: true

  validates :full_name, presence: true

  validates :password, length: { minimum: 8 }, allow_nil: true

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

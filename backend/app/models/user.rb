class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :orders, dependent: :destroy

  enum :role, {
    user: 0,
    admin: 1
  }

  before_validation :set_default_role, on: :create

  def set_default_role
    self.role ||= :user
  end
end

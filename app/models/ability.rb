class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    return unless user.persisted?

    can :manage, Movement, user_id: user.id
    can :manage, Group, user_id: user.id
  end
end

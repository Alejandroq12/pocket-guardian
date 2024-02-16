class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.persisted?
      can :read, Movement, user_id: user.id
      can :manage, Movement, user_id: user.id
      can :read, Group, user_id: user.id
      can :manage, Group, user_id: user.id
    end
  end
end

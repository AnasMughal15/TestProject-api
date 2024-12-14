class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.manager?
      # debugger
      can :manage, Project, manager_id: user.id
      can :assign_developer, Project
      can :read, Bug
      can :update, Bug
    elsif user.developer?
      can :read, Project
      can :update, Bug
      can :read, Bug
    elsif user.qa?
      can :read, Project
      can :manage, Bug
    end
  end
end

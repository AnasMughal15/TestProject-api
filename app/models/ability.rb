class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.manager?
      # debugger
      can :manage, Project, manager_id: user.id
      can :assign_developer, Project # custom action to assign developers to project
      can :manage, Bug
    elsif user.developer?
      can :read, Project # Developers can only read projects they're assigned to
      can :update, Bug
      can :read, Bug
    elsif user.qa?
      can :read, Project
      can :manage, Bug # If you want QA to have permissions on bugs, you can define here
    end
  end
end

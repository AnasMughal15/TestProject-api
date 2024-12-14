require 'rails_helper'

RSpec.describe ProjectsController, type: :controllers do
  let(:manager) { User.create!(name: "Manager", email: "manager12356789@example.com", user_type: "manager", password: "123456") }
  let(:developer) { User.create!(name: "Developer", email: "developer@example.com", user_type: "developer", password: "123456") }
  let(:qa) { User.create!(name: "QA", email: "qa@example.com", user_type: "qa", password: "password") }

  context "when user is a manager" do
    it "allows the manager to create a project" do
      project = Project.new(name: "New Project", description: "Project Description", manager_id: manager.id)

      expect(project.save).to be_truthy
      expect(Project.count).to eq(1)
    end
  end

  context "when user is a developer" do
    it "does not allow the developer to create a project" do
      project = Project.new(name: "New Project", description: "Project Description", manager_id: developer.id)

      expect(project.save).to be_falsey
      expect(Project.count).to eq(0)
    end
  end

  context "when user is a QA" do
    it "does not allow the QA to create a project" do
      project = Project.new(name: "New Project", description: "Project Description", manager_id: qa.id)

      expect(project.save).to be_falsey
      expect(Project.count).to eq(0)
    end
  end
end

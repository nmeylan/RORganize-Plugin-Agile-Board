require 'ffaker'
namespace :ffaker do
  namespace :generate do
    desc 'Generate fake data for user stories with ffaker.'
    task :user_stories => :environment do
      raise "Missing project_id parameter!\ne.g: rake ffaker:generate:user_stories project_id=1" if (project_id = ENV['project_id']).blank?
      iterations = ENV['i'] ? ENV['i'].to_i : 6_000
      project = Project.includes(:categories, :versions, :trackers).find_by_id(project_id)
      members = Member.where(project_id: project_id).eager_load(:user)
      board = Board.includes(:epics, :story_statuses, :story_points).find_by_project_id(project_id)
      categories = project.categories
      trackers = project.trackers
      statuses = board.story_statuses
      points = board.story_points
      epics = board.epics

      iterations.times do
        User.current = members[rand(0..members.count)].user
        us = UserStory.new(board_id: board.id)
        us.title = Faker::Lorem.sentences(rand(1..2)).join('')
        us.description = Faker::Lorem.paragraph(2)
        us.category = categories[rand(0..categories.count)]
        us.tracker = trackers[rand(0..trackers.count)]
        us.status = statuses[rand(0..statuses.count)]
        us.points = points[rand(0..points.count)]
        us.epic = epics[rand(0..epics.count)]
        us.save
      end
    end
  end
end
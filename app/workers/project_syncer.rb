class ProjectSyncer
  include Sidekiq::Worker

  def perform()
    puts "Sidekiq for ProjectSyncer STARTING"
    Rails.application.routes.default_url_options[:host] = (ENV["HOST_URL"] || 'localhost:3000')

    # Cria o cron worker novamente para o dia de amanha
    ProjectSyncer.start

    diff = 30.seconds
    delay = 0
    User.all.each do |user|
      if user.trello_client
        delay = delay + diff
        ProjectSyncer.delay_for(delay).sync_user(user.id)
      end
    end

    puts "Sidekiq for ProjectSyncer FINISHED"
  end

  def self.start
    set = Sidekiq::ScheduledSet.new
    jobs = set.select {|job| job.klass == 'ProjectSyncer' }
    if jobs.length == 0
      interval = 1.hour
      ProjectSyncer.perform_in(interval)
    end
  end
end
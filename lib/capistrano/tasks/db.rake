namespace :db do
  desc 'Run rake db:migrate'

  task :create do
    on roles(:app) do
      within current_path do
        execute :rake, "db:create RAILS_ENV=#{fetch(:stage)}"
      end
    end
  end

  task :seed do
    on roles(:app) do
      within current_path do
        execute :rake, "db:seed RAILS_ENV=#{fetch(:stage)}"
      end
    end
  end
end
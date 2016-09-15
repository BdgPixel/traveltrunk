namespace :setup do
  desc 'Copy files from application to shared directory'

  task :copy_config_files do
    on roles(:app) do
      fetch(:config_dirs).each do |dirname|
        path = File.join shared_path, dirname
        execute "mkdir -p #{path}"
      end

      fetch(:config_files).each do |filename|
        remote_path = File.join shared_path, filename
        upload! filename, remote_path
      end
    end
  end
end

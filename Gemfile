source "http://www.rubygems.org"
 
gemspec

gem 'lims-core', '~>3.1', :git => 'http://github.com/sanger/lims-core.git' , :branch => 'development'
gem 'lims-busclient', '~>0.4.0', :git => 'https://github.com/sanger/lims-busclient.git' , :branch => 'development'
gem 'lims-management-app', '~>3.0', :git => 'https://github.com/sanger/lims-management-app.git', :branch => 'development'
gem 'lims-exception-notifier-app', '~>0.1.2', :git => 'http://github.com/sanger/lims-exception-notifier-app.git', :branch => 'master'

group :development do
  gem 'sqlite3', :platforms => :mri
end

group :debugger do
  gem 'debugger'
  gem 'debugger-completion'
  gem 'shotgun'
end

group :deployment do
  gem "psd_logger", :git => "http://github.com/sanger/psd_logger.git"
end

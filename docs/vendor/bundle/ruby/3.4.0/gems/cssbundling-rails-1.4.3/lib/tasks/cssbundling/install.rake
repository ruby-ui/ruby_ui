namespace :css do
  namespace :install do
    desc "Install Tailwind"
    task :tailwind do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/tailwind/install.rb",  __dir__)}"
    end

    desc "Install PostCSS"
    task :postcss do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/postcss/install.rb",  __dir__)}"
    end

    desc "Install Sass"
    task :sass do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/sass/install.rb",  __dir__)}"
    end

    desc "Install Bootstrap"
    task :bootstrap do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/bootstrap/install.rb",  __dir__)}"
    end

    desc "Install Bulma"
    task :bulma do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../../install/bulma/install.rb",  __dir__)}"
    end
  end
end

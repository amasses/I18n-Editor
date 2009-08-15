class FileListStore
  def self.get_files
    f = YAML.load_file("#{RAILS_ROOT}/tmp/selected_files.yml")
  end

  def self.store_files(files)
    File.open("#{RAILS_ROOT}/tmp/selected_files.yml", "w") do |out|
      YAML.dump(files, out)
    end
  end

  def self.clear_files
    File.delete "#{RAILS_ROOT}/tmp/selected_files.yml"
  end
end
require 'ftools'

class EditorController < ApplicationController
  before_filter :get_files, :except => [:choose_directory, :select_files, :set_files]

  def choose_directory
    @dir = session[:chosen_directory]
  end

  def select_files
    if params[:directory].nil?
      flash[:notice] = "Sorry, you need to specify a directory."
      redirect_to "/editor/choose_directory" and return
    end

    session[:chosen_directory] = params[:directory]
    dir = params[:directory]
    dir = "#{dir}/" unless dir.ends_with? "/"
    @files = Dir["#{dir}*.yml"]
    
    if @files.size == 0
      flash[:notice] = "No .yml files in '#{dir}'..."
      redirect_to "/editor/choose_directory" and return
    end
  end

  def set_files
    if params[:selected_files].nil?
      flash[:notice] = "Please select at least one file."
      redirect_to "/editor/choose_directory" and return
    end

    FileListStore.store_files params[:selected_files]
    # Backup files!
    params[:selected_files].each do |file|
      File.copy(file, "#{file}.backup")
    end

    directory = File.dirname(params[:selected_files].first)
    system("tar", "zcvf", "#{directory}/backup_#{Time.now.to_formatted_s(:short).gsub(/[^a-z0-9]/i, "_")}.tgz", "#{directory}/*.backup")

    redirect_to "/editor/show_translations"
  end

  def clear_selected_files
    FileListStore.clear_files
    flash[:notice] = "The selected file list has been cleared."
    redirect_to "/editor/choose_directory"
  end

  def show_translations
    @translations = {}


    @files.each do |file|
      yaml = YAML.load_file(file)
      @translations.merge!(yaml)
    end

    @base_translations = @translations.delete("en")
  end

  def add_translation
  end

  def delete_translation
    if params[:key].nil?
      flash[:notice] = "Please select a translation to be deleted."
      redirect_to "/editor/show_translations" and return
    end
    key = params[:key]

    manipulate_files do |lang, translation|
      translation.delete(key)
    end

    flash[:notice] = "Deleted the translation <strong>#{key}</strong>!"
    redirect_to "/editor/show_translations"
  end

  def rename_translation
    @translation = params[:key]
  end

  def save_rename_translation
    if params[:new_translation_name].nil? or params[:new_translation_name].empty?
      flash[:notice] = "Sorry, you need to provide a new translation name."
      @translation = params[:original_key]
      render :rename_translation and return
    end

    key = params[:original_key]
    new_key = params[:new_translation_name]
    
    manipulate_files do |lang, translations|
      orig = translations.delete(key)
      translations[new_key] = orig
    end

    flash[:notice] = "Renamed <strong>#{key}</strong> to <strong>#{new_key}</strong>"
    redirect_to "/editor/show_translations##{new_key}"
  end

  def save_translation
    language = params[:language]
    key = params[:trans_key]
    new_value = params[:value]

    manipulate_files do |lang, translations|
      # Just set the new value!
      translations[key] = new_value if lang == language
    end
  end

  def save_new_translation
    if params[:key_name].nil? or params[:key_name].empty?
      flash[:notice] = "A translation key name is required."
      redirect_to "/editor/add_translation" and return
    end

    key = params[:key_name].gsub(/[^a-z0-9]/i, "_")
    trans_entries = params[:value]

    manipulate_files do |lang, translations|
      translations[key] = trans_entries[lang]
    end

    flash[:notice] = "New translation has been created"
    redirect_to "/editor/show_translations##{key}"
  end

  def index
  end

  private 
  def manipulate_files
    @files.each do |file|
      yaml = YAML.load_file file
      yaml.each_pair do |lang, translations|
        yield lang, translations
      end

      File.open(file, 'w') do |out|
        YAML.dump(yaml, out)
      end
    end
  end

  def get_files
    begin
      @files = FileListStore.get_files

      @languages = []
      manipulate_files do |lang, translations|
         @languages << lang unless @languages.include? lang
      end
      
    rescue
      flash[:notice] = "Couldn't find the list of files selected - please start again."
      redirect_to "/editor/choose_directory" and return
    end
  end
end

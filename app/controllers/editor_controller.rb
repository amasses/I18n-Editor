require 'ftools'

class EditorController < ApplicationController
  def choose_directory
  end

  def select_files
    if params[:directory].nil?
      flash[:notice] = "Sorry, you need to specify a directory."
      redirect_to "/editor/choose_directory" and return
    end

    dir = params[:directory]
    @files = Dir.glob("#{dir}*.yml")
  end

  def set_files
    if params[:selected_files].nil?
      flash[:notice] = "Please select at least one file."
      redirect_to "/editor/choose_directory" and return
    end

    session[:files] = params[:selected_files]
    # Backup files!
    params[:selected_files].each do |file|
      File.copy(file, "#{file}.backup")
    end

    directory = File.dirname(params[:selected_files].first)
    system("tar", "zcvf", "#{directory}/backup_#{Time.now.to_formatted_s(:short).gsub(/[^a-z0-9]/i, "_")}.tgz", "#{directory}/*.backup")

    redirect_to "/editor/show_translations"
  end

  def show_translations
    @translations = {}

    files = session[:files]
    files.each do |file|
      yaml = YAML.load_file(file)
      @translations.merge!(yaml)
    end

    @base_translations = @translations.delete("en")
  end

  def add_translation
  end

  def delete_translation
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
    
    files = session[:files]
    files.each do |file|
      yaml = YAML.load_file file
      yaml.each_pair do |lang, translations|

          orig = translations.delete(key)
          translations[key] = orig
      end

      
    end
    
  end

  def save_translation
  end

  def index
  end

end

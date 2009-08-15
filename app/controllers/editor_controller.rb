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
    redirect_to "/editor/show_translations"
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

  def index
  end

  private 
  def manipulate_files
    files = session[:files]
    files.each do |file|
      yaml = YAML.load_file file
      yaml.each_pair do |lang, translations|
        yield lang, translations
      end

      File.open(file, 'w') do |out|
        YAML.dump(yaml, out)
      end
    end
  end
end
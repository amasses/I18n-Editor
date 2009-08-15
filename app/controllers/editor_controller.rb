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
  end

  def save_translation
  end

  def index
  end

end

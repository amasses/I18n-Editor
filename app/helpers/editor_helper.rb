module EditorHelper

  def o(text)
    text = "<span class=\"empty\">Empty</span>" if text.blank?
    text
  end
end

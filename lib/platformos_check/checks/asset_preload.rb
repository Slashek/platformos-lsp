# frozen_string_literal: true

module PlatformosCheck
  class AssetPreload < HtmlCheck
    severity :suggestion
    categories :html, :performance
    doc docs_url(__FILE__)

    def on_link(node)
      return if node.attributes["rel"]&.downcase != "preload"

      case node.attributes["as"]&.downcase
      when "style"
        add_offense("For better performance, prefer using the preload argument of the stylesheet_tag filter", node:)
      when "image"
        add_offense("For better performance, prefer using the preload argument of the image_tag filter", node:)
      else
        add_offense("For better performance, prefer using the preload_tag filter", node:)
      end
    end
  end
end

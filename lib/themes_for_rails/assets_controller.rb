require "action_controller/metal"

module ThemesForRails
  class AssetsController < ActionController::Base

    include ThemesForRails::CommonMethods
    include ThemesForRails::UrlHelpers

    def stylesheets
      handle_asset(params[:asset], params[:theme], "stylesheets")
    end

    def javascripts
      handle_asset(params[:asset], params[:theme], "javascripts")
    end

    def images
      #raise params.inspect
      #handle_asset(params[:asset], params[:theme], "images")
      handle_asset(params[:asset], params[:theme], "assets/images")
    end

  private

    def handle_asset(asset, theme, prefix)
      find_themed_asset(asset, theme, prefix) do |path, mime_type|
        send_file path, :type => mime_type, :disposition => "inline"
      end
    end

    def find_themed_asset(asset_name, asset_theme, asset_prefix, &block)
      path = asset_path(asset_name, asset_theme, asset_prefix)
      if File.exists?(path)
        yield path, mime_type_for(request)
      elsif File.extname(path).blank?
        asset_name = "#{asset_name}.#{extension_from(request.path_info)}"
        return find_themed_asset(asset_name, asset_theme, asset_prefix, &block)
      else
        render_not_found
      end
    end

    def asset_path(asset_name, asset_theme, asset_prefix)
      File.join(theme_path_for(asset_theme), asset_prefix, asset_name)
    end
    alias_method :raj_asset_path, :asset_path

    def render_not_found
      render :text => 'not found', :status => 404
    end

    def mime_type_for(request)
      existing_mime_type = mime_type_from_uri(request.path_info)
      unless existing_mime_type.nil?
        existing_mime_type.to_s
      else
        "image/#{extension_from(request.path_info)}"
      end
    end

    def mime_type_from_uri(path)
      extension = extension_from(path)
      Mime::Type.lookup_by_extension(extension)
    end

    def extension_from(path)
      File.extname(path).to_s[1..-1]
    end
  end
end

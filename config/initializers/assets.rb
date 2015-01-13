# Adapted from http://guides.rubyonrails.org/v4.0.2/asset_pipeline.html#precompiling-assets

Rails.application.config.assets.precompile << Proc.new do |path|
  if path =~ %r{\A[^_].*\.(css|js)\Z}
    full_path = Rails.application.assets.resolve(path).to_path
    app_assets_path = Rails.root.join('app', 'assets').to_path
    if full_path.starts_with? app_assets_path
      puts "including asset: " + full_path
      true
    else
      puts "excluding asset: " + full_path
      false
    end
  else
    false
  end
end
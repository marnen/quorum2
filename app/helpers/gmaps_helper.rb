module GmapsHelper
  def gmaps_api_key
    GMAPS_API_KEY.kind_of?(Hash) ? GMAPS_API_KEY[controller.request.host_with_port] : GMAPS_API_KEY
  end
end
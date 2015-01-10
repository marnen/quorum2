module ResourceParams
  def resource_params
    params.require(resource_name).permit *resource_class.permitted_params
  end

  private

  def resource_name
    self.class.name.chomp("Controller").singularize.underscore.to_sym
  end

  def resource_class
    Module.const_get self.class.name.chomp("Controller").singularize
  end
end
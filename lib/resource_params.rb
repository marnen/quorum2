module ResourceParams
  def resource_params
    params.require(resource_name).permit *resource_class.permitted_params
  end

  private

  def resource_name
    resource_class_name.underscore.to_sym
  end

  def resource_class
    Module.const_get resource_class_name
  end

  def resource_class_name
    self.class.name.chomp("Controller").singularize
  end
end
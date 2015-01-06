# TODO: remove when we upgrade to 4.1.  Better yet, submit a pull request; this fixes a bug in 4.0.

ActiveSupport::SafeBuffer.class_eval do
  def %(args)
    case args
    when Array
      safe_args = Array(args).map do |arg|
        if !html_safe? || arg.html_safe?
          arg
        else
          ERB::Util.h(arg)
        end
      end
    when Hash
      safe_args = Hash[
        args.map do |key, value|
          safe_value = if !html_safe? || value.html_safe?
            value
          else
            ERB::Util.h(value)
          end
          [key, safe_value]
        end
      ]
    else
      raise ArgumentError, 'expected an Array or Hash'
    end

    self.class.new(super(safe_args))
  end
end
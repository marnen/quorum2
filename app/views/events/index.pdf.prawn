pdf.font 'Times-Roman'
data = @users.collect do |u|
  name = [u.lastname, u.firstname].compact
  row = [(name.blank? ? u.email : name.join(', '))] + @events.collect do |e|
    case attendance_status(e, u)
      when :yes
        _('Y')
      when :no
        _('N')
      else
        ''
    end
  end
  row
end

pdf.table data, :headers => [''] + @events.collect{|x| [x.name, [x.city, x.state.code].compact.join(', '), x.date.to_s(:rfc822)].compact.join("\n")}, :align => :left, :align_headers => :center, :font_size => 10, :border_width => 0.5, :border_style => :grid
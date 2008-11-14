pdf.font 'Times-Roman'
data = @users.collect do |u|
  row = []
  name = [u.lastname, u.firstname].compact
  row << (name.blank? ? u.email : name.join(', '))
  row = row + @events.collect do |e|
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
pdf.table data, :headers => [''] + @events.collect{|x| x.name}, :align_headers => :center, :font_size => 10, :border_width => 0.5, :border_style => :grid
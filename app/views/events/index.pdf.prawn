begin
  pdf.font_families.update('DejaVu' => {
    :normal => "#{FONT_ROOT}/DejaVuSerif.ttf",
    :bold => "#{FONT_ROOT}/DejaVuSerif-Bold.ttf",
    :italic => "#{FONT_ROOT}/DejaVuSerif-Italic.ttf",
    :bold_italic => "#{FONT_ROOT}/DejaVuSerif-BoldItalic.ttf",
  })
  
  pdf.font 'DejaVu'
rescue
  pdf.font 'Times-Roman'
end
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

title = _("Attendance Report for %{calendar}") % {:calendar => @events[0].calendar} # we only ever have events from one calendar, so this is sufficient
subtitle = _('Generated %{date}') % {:date => Time.zone.now.to_formatted_s(:rfc822)}

pdf.header pdf.margin_box.top_left do
  if pdf.page_count > 1
    pdf.font_size(8) do
      left = subtitle
      center = title
      right = _('page %{page}') % {:page => pdf.page_count}
      pdf.text left, :align => :left
      pdf.move_up(pdf.height_of(left, pdf.margin_box.width))
      pdf.text center, :align => :center
      pdf.move_up(pdf.height_of(center, pdf.margin_box.width))
      pdf.text right, :align => :right
    end
  end
end
  
pdf.pad_bottom(4) do
  pdf.text title, :align => :center, :size => 14, :style => :bold
  pdf.text subtitle, :align => :center, :size => 12
end

if data == []
  pdf.text _('No events found.'), :align => :center, :size => 14
else
  headers = [''] + @events.collect do |x|
    [x.name, [x.city, x.state.code].compact.join(', '), x.date.to_s(:rfc822)].compact.join("\n")
  end
  
  pdf.table data, :headers => headers, :align => :left, :align_headers => :center, :font_size => 9, :border_width => 0.5, :border_style => :grid
end
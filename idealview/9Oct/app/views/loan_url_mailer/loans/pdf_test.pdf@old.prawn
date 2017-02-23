pdf.text "lOANS ##{@loans.id}", :size => 30, :style => :bold

pdf.move_down(30)

items = @loans do |item|
  [
    item.info['_LoanName'],
    item.info['email'],
  ]
end

pdf.table items, :border_style => :grid,
  :row_colors => ["FFFFFF","DDDDDD"],
  :headers => ["Name", "Email"],
  :align => { 0 => :left, 1 => :right, 2 => :right, 3 => :right }

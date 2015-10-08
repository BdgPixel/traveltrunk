module DealsHelper
  def guests_list
    (1..16).to_a.map do |n|
      label = pluralize(n, "Guest")
      label.gsub!(" ", "+ ") if n.eql?(16)
      [label, n]
    end
  end
end


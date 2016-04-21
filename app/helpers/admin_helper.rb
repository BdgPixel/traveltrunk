module AdminHelper
  def status_label(status)
    if ['yes', 'reserved'].include? status
      'label label-success'
    elsif ['pending', 'refunded'].include? status
      'label label-warning'
    else
      'label label-default'
    end
  end
end
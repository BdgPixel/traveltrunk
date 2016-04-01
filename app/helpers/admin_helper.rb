module AdminHelper
  def status_label(status)
    if status.eql? 'yes'
      'label label-success'
    elsif status.eql? 'pending'
      'label label-warning'
    else
      'label label-default'
    end
  end
end
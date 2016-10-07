module ExceptionErrorResponse
  def error_message(e)
    if e.is_a?(AuthorizeNetLib::RescueErrorsResponse)
      @error_response = 
        if e.error_message[:response_error_text]
          "#{e.error_message[:response_message]} #{e.error_message[:response_error_text]}"
        else
          e.error_message[:response_message].split('-').last.strip
        end
    else
      logger.error e.message
      e.backtrace.each { |line| logger.error line }
      @error_response = 'Some errors occurred, please try again'
    end

    false
  end
end

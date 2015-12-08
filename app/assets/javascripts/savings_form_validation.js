$('#formAddToSavings').on('submit', function(e) {
  var returnValue;
  returnValue = void 0;
  returnValue = null;

  if (!$('#update_credit_amount').val()) {
    $('.payment-errors').html('Amount cannot be blank or zero or negative');
    returnValue = false;
  }

  if ($('#update_credit_amount').val() == 0) {
    $('.payment-errors').html('Amount cannot be blank or zero or negative');
    returnValue = false;
  }

  if ($('#update_credit_amount').val() < 0) {
    $('.payment-errors').html('Amount cannot be blank or zero or negative');
    returnValue = false;
  }

  return returnValue;
});

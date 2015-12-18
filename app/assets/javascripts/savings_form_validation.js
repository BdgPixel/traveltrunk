
$('#formAddToSavings').on('submit', function(e) {
  var returnValue;
  returnValue = void 0;
  returnValue = null;

  if ($('#update_credit_cvv').val().length < 3) {
    $('.payment-errors').html('Cvv is too short (minimum is 3 characters)');
    returnValue = false;
  }

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

$(document).ready(function() {
  $('#modalSavingsForm').on('hidden.bs.modal', function(e) {
    $('#formAddToSavings').get(0).reset();
    $('.payment-errors').html("");
  });
});

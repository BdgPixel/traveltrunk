
$('form.transaction-form').on('submit', function(e) {
  var returnValue;
  returnValue = void 0;
  returnValue = null;

  if ($('.card_number').val().length < 4) {
    $('.payment-errors').html('Credit card number is too short.');
    returnValue = false;
  }

  if ($('.card_number').val().length > 16) {
    $('.payment-errors').html('Credit card number is too long.');
    returnValue = false;
  }

  if ($('.cvc').val().length < 3) {
    $('.payment-errors').html('Cvv is too short (minimum is 3 characters)');
    returnValue = false;
  }

  if (!$('.amount').val()) {
    $('.payment-errors').html('Amount cannot be blank or zero or negative');
    returnValue = false;
  }

  if ($('.amount').val() == 0) {
    $('.payment-errors').html('Amount cannot be blank or zero or negative');
    returnValue = false;
  }

  if ($('.amount').val() < 0) {
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

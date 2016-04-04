
$('form.transaction-form').on('submit', function(e) {
  var returnValue;
  returnValue = void 0;
  returnValue = null;

  if ($('.card_number').val().length < 4) {
    $('.payment-errors').html('Credit card number is too short.');
    returnValue = false;
  }else if ($('.card_number').val().length > 16) {
    $('.payment-errors').html('Credit card number is too long.');
    returnValue = false;
  }else if ($('.cvc').val().length < 3) {
    $('.payment-errors').html('Cvv is too short (minimum is 3 characters)');
    returnValue = false;
  }else if (!$('.amount').val()) {
    $('.payment-errors').html('Amount cannot be blank or zero or negative');
    returnValue = false;
  }else if ($('.amount').val() == 0) {
    $('.payment-errors').html('Amount cannot be blank or zero or negative');
    returnValue = false;
  }else if ($('.amount').val() < 0) {
    $('.payment-errors').html('Amount cannot be blank or zero or negative');
    returnValue = false;
  }else if ($('.transfer_frequency').val() == 0) {
    $('.payment-errors').html('Please select one tranfer frequency');
    returnValue = false;
  }

  return returnValue;
});

$(document).ready(function() {
  $('#modalSavingsForm').on('hidden.bs.modal', function(e) {
    $('#formAddToSavings').get(0).reset();
    $('.payment-errors').html("");
  });

  $(".card_number").keydown(function (e) {
    // Allow: backspace, delete, tab, escape, enter and .
    if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
      // Allow: Ctrl+A
      (e.keyCode == 65 && e.ctrlKey === true) ||
       // Allow: Ctrl+C
      (e.keyCode == 67 && e.ctrlKey === true) ||
       // Allow: Ctrl+X
      (e.keyCode == 88 && e.ctrlKey === true) ||
       // Allow: Ctrl+V
      (e.keyCode == 86 && e.ctrlKey === true) ||
       // Allow: home, end, left, right
      (e.keyCode >= 35 && e.keyCode <= 39)) {
        // let it happen, don't do anything
        return;
    }

    // Ensure that it is a number and stop the keypress
    if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
      e.preventDefault();
    }
});


});

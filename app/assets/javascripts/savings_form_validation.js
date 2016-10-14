validationForm = function() {
  $('form.transaction-form').on('submit', function(e) {
    var returnValue;
    returnValue = void 0;
    returnValue = null;

    if ($('.card_number').val().length < 13) {
      $('.payment-errors').html('Credit card number is too short.');
      returnValue = false;
    } else if ($('.card_number').val().length > 16) {
      $('.payment-errors').html('Credit card number is too long.');
      returnValue = false;
    } else if ($('.cvc').val().length < 3) {
      $('.payment-errors').html('Cvv is too short (minimum is 3 characters)');
      returnValue = false;
    } else if ($('.card-month').val() < (new Date().getMonth() + 1)) {
      $('.payment-errors').html('Please select present or future month');
      returnValue = false;
    } else if (!$('.amount').val()) {
      $('.payment-errors').html('Amount cannot be blank or zero or negative');
      returnValue = false;
    } else if ($('.amount').val() == 0) {
      $('.payment-errors').html('Amount cannot be blank or zero or negative');
      returnValue = false;
    } else if ($('.amount').val() < 0) {
      $('.payment-errors').html('Amount cannot be blank or zero or negative');
      returnValue = false;
    } else if ($('.transfer_frequency').val() == 0) {
      $('.payment-errors').html('Please select one transfer frequency');
      returnValue = false;
    }

    if ($('#profile').length > 0) {
      if ($('.first-name').val() == 0) {
        $('.payment-errors').html('First name cannot be blank or zero');
        returnValue = false; 
      } else if ($('.last-name').val() == 0) {
        $('.payment-errors').html('Last name cannot be blank or zero');
        returnValue = false; 
      } else if ($('.address').val() == 0) {
        $('.payment-errors').html('Address cannot be blank or zero');
        returnValue = false; 
      } else if ($('.city').val() == 0) {
        $('.payment-errors').html('City cannot be blank or zero');
        returnValue = false; 
      } else if ($('.state').val() == 0) {
        $('.payment-errors').html('State cannot be blank or zero');
        returnValue = false; 
      } else if ($('.home-phone').val() == '') {
        $('.payment-errors').html('Phone number cannot be blank');
        returnValue = false;
      } else if ($('.zip').val() == 0) {
        $('.payment-errors').html('Zip or postal code cannot be blank or zero');
        returnValue = false;
      } else if ($('.email-saving').val() == 0) {
        $('.payment-errors').html('Email cannot be blank or zero');
        returnValue = false;
      } else if (validateEmail($('.email-saving').val()) == false) {
        $('.payment-errors').html('Email not valid format');
        returnValue = false;
      } else if ($('.country').val() == '') {
        $('.payment-errors').html('Please select one a country code');
        returnValue = false;
      } else if ($('.card-type').val() == '') {
        $('.payment-errors').html('Please select your card type');
        returnValue = false;
      }
    }
    
    $("#modalSavingsForm").scrollTop(0);
    return returnValue;
    e.preventDefault()
  });
};

validateEmail = function(email) {
  var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
  return emailReg.test(email);
};

restrictCardNumberAndCsv = function(selector) {
  $(selector).on('change', function() {
    cardType = $(this).val();
    $('.cvc').val('');

    if (cardType == 'CA' || cardType == 'VI')
      $('.cvc').attr('maxlength', 3)
    else
      $('.cvc').attr('maxlength', 4)
  });
};

numericalDigits = function() {
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
};

$(document).ready(function() {
  validationForm();
  $('#modalSavingsForm').on('hidden.bs.modal', function(e) {
    $('#formAddToSavings').get(0).reset();
    $('.payment-errors').html("");
  });

  numericalDigits();
  restrictCardNumberAndCsv('.card-type');
});

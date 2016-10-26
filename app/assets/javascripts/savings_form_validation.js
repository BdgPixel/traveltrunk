savingFormValidation = function() {
  $('form#formAddToSavings').on('submit', function(e) {
    var returnValue;
    returnValue = void 0;
    returnValue = null;
    
    $('.saving-error').text('');

    if ($('.card-type').val() == '') {
      $('.card-type-error').html('Please select your card type');
      returnValue = false;
    }

    if ($('.card_number').val().length < 13) {
      $('.credit-card-error').html('Credit card number is too short.');
      returnValue = false;
    } 

    if ($('.card_number').val().length > 16) {
      $('.credit-card-error').html('Credit card number is too long.');
      returnValue = false;
    } 

    if ($('.cvc').val().length < 3) {
      $('.cvc-error').html('Cvv (min 3)');
      returnValue = false;
    } 

    if ($('.card-month').val() < (new Date().getMonth() + 1)) {
      $('.card-month-error').html('Select present or future month');
      returnValue = false;
    } 

    if ($('.amount').val() == '') {
      $('.amount-error').html('Minimum $25.00');
      returnValue = false;
    }

    if ($('.amount').val() < 25) {
      $('.amount-error').html('Minimum $25.00');
      returnValue = false;
    }
    
    return returnValue;
    e.preventDefault()
  });
}

paymentAccountFormValidation = function() {
  $('form#paymentAccountProfile').on('submit', function(e) {
    console.log('wew');
    var returnValue;
    returnValue = void 0;
    returnValue = null;
    
    $('.payment-account-error').text('');
    $('.error').text('');

    if ($('.card_number').val().length < 13) {
      $('.credit-card-error').html('Credit card number is too short.');
      returnValue = false;
    } 

    if ($('.card_number').val().length > 16) {
      $('.credit-card-error').html('Credit card number is too long.');
      returnValue = false;
    } 

    if ($('.cvc').val().length < 3) {
      $('.cvc-error').html('Cvv (min 3)');
      returnValue = false;
    } 

    if ($('.card-month').val() < (new Date().getMonth() + 1)) {
      $('.card-month-error').html('Select present or future month');
      returnValue = false;
    } 

    if ($('.amount').val() == '') {
      $('.amount-error').html('Minimum $25.00');
      // $('.amount-error').html('Amount transfer must be greater than or equal to $25.00');
      returnValue = false;
    }

    if ($('.amount').val() < 25) {
      $('.amount-error').html('Minimum $25.00');
      returnValue = false;
    }

    if ($('.transfer_frequency').val() == 0) {
      $('.transfer-frequency-error').html('Please select one transfer frequency');
      returnValue = false;
    }
    
    return returnValue;
    e.preventDefault()
  });
}

guestBookingFormValidation = function() {
  $('form#formBookGuest').on('submit', function(e) {
    console.log('yuhuu');
    var returnValue;
    returnValue = void 0;
    returnValue = null;
    
    $('.guest-book-error').text('');

    if ($('.first-name').val() == 0) {
      $('.first-name-error').html('First name cannot be blank or zero');
      returnValue = false; 
    }

    if ($('.last-name').val() == 0) {
      $('.last-name-error').html('Last name cannot be blank or zero');
      returnValue = false; 
    }

    if ($('.address').val() == 0) {
      $('.address-error').html('Address cannot be blank or zero');
      returnValue = false; 
    }

    if ($('.city').val() == 0) {
      $('.city-error').html('City cannot be blank or zero');
      returnValue = false; 
    }

    if ($('.state').val() == 0) {
      $('.state-error').html('State cannot be blank or zero');
      returnValue = false; 
    }

    if ($('.home-phone').val() == '') {
      $('.home-phone-error').html('Phone number cannot be blank');
      returnValue = false;
    }

    if ($('.zip').val() == 0) {
      $('.zip-error').html('Zip required');
      returnValue = false;
    }

    if ($('.email-saving').val() == 0) {
      $('.email-saving-error').html('Email cannot be blank or zero');
      returnValue = false;
    }

    if (validateEmail($('.email-saving').val()) == false) {
      $('.email-saving-error').html('Email not valid format');
      returnValue = false;
    }

    if ($('.country').val() == '') {
      $('.country-error').html('Please select one a country code');
      returnValue = false;
    }

    if ($('.card-type').val() == '') {
      $('.card-type-error').html('Please select your card type');
      returnValue = false;
    }

    if ($('.card_number').val().length < 13) {
      $('.credit-card-error').html('Credit card number is too short.');
      returnValue = false;
    } 

    if ($('.card_number').val().length > 16) {
      $('.credit-card-error').html('Credit card number is too long.');
      returnValue = false;
    } 

    if ($('.cvc').val().length < 3) {
      $('.cvc-error').html('Cvv is too short (min 3)');
      returnValue = false;
    } 

    if ($('.card-month').val() < (new Date().getMonth() + 1)) {
      $('.card-month-error').html('Select present or future month');
      returnValue = false;
    } 
    
    return returnValue;
    e.preventDefault()
  });
};

validationBookForGuest = function() {
  $('form.form-book-guest').on('submit', function(e) {
    var returnValue;
    returnValue = void 0;
    returnValue = null;
    $('.guest-book-error').text('');

    if ($('.card_number').val().length < 13) {
      $('.credit-card-error').html('Credit card number is too short.');
      returnValue = false;
    } 

    if ($('.card_number').val().length > 16) {
      $('.credit-card-error').html('Credit card number is too long.');
      returnValue = false;
    } 

    if ($('.cvc').val().length < 3) {
      $('.cvc-error').html('Cvv is too short (min 3)');
      returnValue = false;
    } 

    if ($('.card-month').val() < (new Date().getMonth() + 1)) {
      $('.card-month-error').html('Select present or future month');
      returnValue = false;
    } 

    if ($('.transfer_frequency').val() == 0) {
      $('.transfer-frequency-error').html('Please select one transfer frequency');
      returnValue = false;
    }

    if ($('.card-type').val() == '') {
      $('.card-type-error').html('Please select your card type');
      returnValue = false;
    }

    if ($('.first-name').val() == 0) {
      $('.first-name-error').html('First name cannot be blank or zero');
      returnValue = false; 
    }

    if ($('.last-name').val() == 0) {
      $('.last-name-error').html('Last name cannot be blank or zero');
      returnValue = false; 
    }

    if ($('.address').val() == 0) {
      $('.address-error').html('Address cannot be blank or zero');
      returnValue = false; 
    }

    if ($('.city').val() == 0) {
      $('.city-error').html('City cannot be blank or zero');
      returnValue = false; 
    }

    if ($('.state').val() == 0) {
      $('.state-error').html('State cannot be blank or zero');
      returnValue = false; 
    }

    if ($('.home-phone').val() == '') {
      $('.home-phone-error').html('Phone number cannot be blank');
      returnValue = false;
    }

    if ($('.zip').val() == 0) {
      $('.zip-error').html('Zip required');
      returnValue = false;
    }

    if ($('.email-saving').val() == 0) {
      $('.email-saving-error').html('Email cannot be blank or zero');
      returnValue = false;
    }

    if (validateEmail($('.email-saving').val()) == false) {
      $('.email-saving-error').html('Email not valid format');
      returnValue = false;
    }

    if ($('.country').val() == '') {
      $('.country-error').html('Please select one a country code');
      returnValue = false;
    }

    return returnValue;
    e.preventDefault()
  });

}

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
  savingFormValidation();

  if ($('form#paymentAccountProfile').length > 0)
    paymentAccountFormValidation();

  if ($('#profile').length > 0)
    guestBookingFormValidation();

  $('#modalSavingsForm').on('hidden.bs.modal', function(e) {
    try {
      $('#formAddToSavings').get(0).reset();
    } catch (e) {}

    try {
      $('#formBookGuest').get(0).reset();
    } catch (e) {}

    clearValidationMessage();
  });

  numericalDigits();
  restrictCardNumberAndCsv('.card-type');
});

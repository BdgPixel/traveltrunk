(function(){var e;Stripe.setPublishableKey("pk_test_vqvpyrmq9OBE6ZscwpZLNs0P"),jQuery(function(t){t("#payment-form").submit(function(r){var n;return n=t(this),n.find("button").prop("disabled",!0),Stripe.card.createToken(n,e),!1})}),e=function(e,t){var r,n;r=$("#payment-form"),t.error?(r.find(".payment-errors").text(t.error.message),r.find("button").prop("disabled",!1)):(console.log(t),n=t.id,r.append($('<input type="hidden" name="stripeToken" />').val(n)),r.get(0).submit())}}).call(this);
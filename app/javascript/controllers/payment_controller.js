import { Controller } from "stimulus";

// Manage Stripe Elements credit card form
export default class extends Controller {
  static targets = [
    'paymentMethods',
    'method',
    'spinner',
    'stripeChargeForm',
    'stripeSubmitButton'
  ];

  showStripeForm() {
    this.stripeChargeFormTarget.classList.remove('d-none')
    this.paymentMethodsTarget.classList.add('d-none')
    this.methodTargets.forEach((method) => { method.classList.add('d-none')})
    this.buildStripElements(this.stripeSubmitButtonTarget.dataset.successUrl)
  }

  hideStripeForm() {
    this.stripeChargeFormTarget.classList.add('d-none')
    this.paymentMethodsTarget.classList.remove('d-none')
    this.methodTargets.forEach((method) => { method.classList.remove('d-none')})
  }


  buildStripElements(successUrl){
    let stripePublishableKey = this.stripeChargeFormTarget.dataset.stripePublishableKey;
    let stripe = Stripe(stripePublishableKey);

    // Create an instance of Elements.
    let locale = this.stripeChargeFormTarget.dataset.locale;
    let elements = stripe.elements({locale: locale});

    let style = {
      base: {
        color: '#32325d',
        fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
        fontSmoothing: 'antialiased',
        fontSize: '16px',
        '::placeholder': {
          color: '#aab7c4'
        }
      },
      invalid: {
        color: '#F05133',
        iconColor: '#F05133'
      }
    };

    // Create an instance of the card Element.
    var card = elements.create('card', {style: style});

    // Add an instance of the card Element into the `card-element` <div>.
    card.mount('#card-element');

    const form = this.stripeChargeFormTarget;
    const submitButton  = this.stripeSubmitButtonTarget
    const clientSecret  = submitButton.dataset.secret
    const displayError = document.getElementById('card-errors');
    const spinner = this.spinnerTarget

    form.addEventListener('submit', function(event) {
      event.preventDefault();
      displayError.textContent = '';
      spinner.classList.remove('d-none')
      submitButton.classList.add('d-none')

      stripe.handleCardPayment(
        clientSecret, card
      ).then(function(result) {
        if (result.error) {
          displayError.textContent = result.error.message;
          spinner.classList.add('d-none')
          submitButton.classList.remove('d-none')
        } else {
          form.submit();
        }
      });
    });
  }
}

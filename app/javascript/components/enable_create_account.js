// Only enable Create account button once both fields have been filled in

function preventCreationWithoutDetails() {
  const submitButton = document.getElementById("sign-up-js");
  submitButton.addEventListener("click", function(e) {
    e.preventDefault();
  const emailField = document.getElementById("email-field-js");
  const passwordField = document.getElementById("password-field-js");
    if (emailField.value === "" && passwordField.value === "") {
      submitButton.disabled = true;
    } else {
      submitButton.disabled = false;
    }
  })
}

export { preventCreationWithoutDetails };

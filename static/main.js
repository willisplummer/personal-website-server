window.onload = () => {
  const btn = document.getElementById('submit-button');

  btn.addEventListener('click', (event) => {
    event.preventDefault();

    const emailInput = document.getElementById('email-input');
    const email = emailInput.value;

    fetch(
      '/api/subscriptions',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email })
      }
    ).then(() => {
      emailInput.value = ''
    });
  });
}

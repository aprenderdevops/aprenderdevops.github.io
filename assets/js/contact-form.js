// Mejora progresiva de _includes/contact-form.html: envía el formulario a
// Formspree por fetch y muestra el resultado en la propia página, como hacía
// Contact Form 7 en el WordPress original. Sin JS, el navegador hace el POST
// normal y Formspree responde con su propia página de "gracias".
(function () {
	var formulario = document.querySelector('.entry-form');
	if (!formulario) return;

	var respuesta = formulario.querySelector('.entry-form-response');
	var boton = formulario.querySelector('input[type="submit"]');

	// Los mismos textos que mostraba Contact Form 7 en español (tomados de su
	// traducción es_ES, para no cambiar lo que leía el visitante).
	var MENSAJE_OK = 'Gracias por tu mensaje. Ha sido enviado.';
	var MENSAJE_ERROR = 'Ha ocurrido un error al intentar enviar tu mensaje. Por favor, inténtalo de nuevo más tarde.';

	function mostrar(texto, clase) {
		respuesta.textContent = texto;
		respuesta.classList.remove('entry-form-response-ok', 'entry-form-response-error');
		respuesta.classList.add(clase);
		respuesta.hidden = false;
	}

	formulario.addEventListener('submit', function (evento) {
		evento.preventDefault();
		boton.disabled = true;
		respuesta.hidden = true;

		// La cabecera Accept es lo que hace que Formspree conteste con JSON en
		// vez de redirigir a su página de "gracias".
		fetch(formulario.action, {
			method: 'POST',
			body: new FormData(formulario),
			headers: { Accept: 'application/json' }
		}).then(function (httpRespuesta) {
			if (!httpRespuesta.ok) throw new Error(httpRespuesta.status);
			mostrar(MENSAJE_OK, 'entry-form-response-ok');
			formulario.reset();
		}).catch(function () {
			mostrar(MENSAJE_ERROR, 'entry-form-response-error');
		}).finally(function () {
			boton.disabled = false;
		});
	});
})();

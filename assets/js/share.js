// Mejora progresiva de _includes/share.html: si el navegador soporta la Web
// Share API nativa (típicamente móvil), muestra el botón "Compartir con
// otra app" (oculto por defecto con el atributo `hidden`) y lo conecta al
// selector de apps del sistema. Sin soporte, el resto de enlaces fijos
// (LinkedIn, X, WhatsApp, correo) siguen funcionando igual.
(function () {
	if (!navigator.share) return;

	var boton = document.querySelector('.entry-share-native');
	if (!boton) return;

	boton.hidden = false;
	boton.addEventListener('click', function () {
		navigator.share({
			title: boton.dataset.shareTitle,
			url: boton.dataset.shareUrl
		}).catch(function () {
			// El usuario cancela el selector o el navegador rechaza la
			// llamada: no hay nada que hacer ni que mostrar.
		});
	});
})();

// Reescritura sin jQuery del menú responsive de Genesis (detalle "Sí se mantiene" del plan).
document.addEventListener('DOMContentLoaded', function () {
	var menus = document.querySelectorAll('header .genesis-nav-menu, .nav-primary .genesis-nav-menu');

	menus.forEach(function (menu) {
		menu.classList.add('responsive-menu');

		var icon = document.createElement('div');
		icon.className = 'responsive-menu-icon';
		menu.parentNode.insertBefore(icon, menu);

		icon.addEventListener('click', function () {
			if (menu.style.display === 'block') {
				menu.style.display = 'none';
			} else {
				menu.style.display = 'block';
			}
		});

		var items = menu.querySelectorAll(':scope > .menu-item');
		items.forEach(function (item) {
			item.addEventListener('click', function (event) {
				if (event.target !== item) {
					return;
				}
				var subMenu = item.querySelector('.sub-menu');
				if (!subMenu) {
					return;
				}
				if (subMenu.style.display === 'block') {
					subMenu.style.display = 'none';
				} else {
					subMenu.style.display = 'block';
				}
				item.classList.toggle('menu-open');
			});
		});
	});

	window.addEventListener('resize', function () {
		if (window.innerWidth > 768) {
			document.querySelectorAll('header .genesis-nav-menu, .nav-primary .genesis-nav-menu, nav .sub-menu').forEach(function (el) {
				el.removeAttribute('style');
			});
			document.querySelectorAll('.responsive-menu > .menu-item').forEach(function (el) {
				el.classList.remove('menu-open');
			});
		}
	});
});

/**
 * @author marnen@marnen.org
 */

function init() {
	Event.addBehavior({
		// 'form.attendance': Remote,
		'form.attendance input[type=submit]': function() {
			this.style.display = 'none';
		},
		'form.attendance select.commit:change': function(event) {
			this.form.request();
		}
	});
	/* var selectors = $$('form.attendance select.commit');
	selectors.each(function (s) {
		s.observe('change', function(event) {
			event.findElement('form').request();
		});
	}) */
};

Event.observe(window, 'load', init);

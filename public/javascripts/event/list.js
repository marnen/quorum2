/**
 * @author marnen@marnen.org
 */

function ajaxify_page() {
	 Event.addBehavior({
    // 'form.attendance': Remote,
    'form.attendance input[type=submit]': function () {
      this.hide();
    },
    'form.attendance select.commit:change': ajaxify_form
  });
};

function ajaxify_form(event) {
  var myForm = event.findElement('form');
  myForm.request({
    onSuccess: function(transport) {
      var row = myForm.up('tr');
      var id = row.id;
			row.replace(transport.responseText);
			var newForm = $(id).down('form.attendance');
			newForm.down('input[type=submit]').hide();
			newForm.down('select.commit').observe('change', ajaxify_form);
    }
  });
};

function init() {
	ajaxify_page();
};

Event.observe(window, 'load', init);

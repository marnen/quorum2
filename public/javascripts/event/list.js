/**
 * @author marnen@marnen.org
 */

// preload the progress spinner
var progress_gif = new Image();
progress_gif.src = '/images/progress.gif';

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
	var progress = myForm.down('.progress');
  myForm.request({
		onLoading: function () {
			progress.appendChild(spinner());
		},
    onSuccess: function(transport) {
      var row = myForm.up('tr');
      var id = row.id;
			row.replace(transport.responseText);
			var newForm = $(id).down('form.attendance');
			newForm.down('input[type=submit]').hide();
			newForm.down('select.commit').observe('change', ajaxify_form);
    },
		onFailure: function () {
			progress.descendants.each(remove);
		}
  });
};

// return a progress spinner image
function spinner() {
	var img = document.createElement('img');
	img.src = progress_gif.src;
	return img;
}

function init() {
	ajaxify_page();
};

Event.observe(window, 'load', init);

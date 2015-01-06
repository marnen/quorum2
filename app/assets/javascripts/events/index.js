/**
 * @author marnen@marnen.org
 */

// preload the progress spinner
var progress_gif = new Image();
progress_gif.src = '/assets/progress.gif';

function ajaxify_page() {
   Event.addBehavior({
    // 'form.attendance': Remote,
    '.progress': this.prepare_spinner,
    'form.attendance input[type=submit]': function () {
      this.hide();
    },
    'form.attendance textarea:blur': ajaxify_form,
    'form.attendance select.commit:change': ajaxify_form
  });
};

function ajaxify_form(event) {
  var myForm = event.findElement('form');
  var progress = myForm.down('.progress');
  myForm.request({
    onLoading: function () {
      progress.replaceChild(spinner(), progress.firstChild);
    },
    onSuccess: function(transport) {
      var row = myForm.up('tr');
      var id = row.id;
      row.replace(transport.responseText);
      var newForm = $(id).down('form.attendance');

      // TODO: these statements repeat ajaxify_page; can we do better?
      newForm.down('input[type=submit]').hide();
      newForm.down('select.commit').observe('change', ajaxify_form);
      newForm.down('textarea').observe('blur', ajaxify_form);
			f = prepare_spinner.bind(newForm.down('.progress'));
			f();
    },
    onFailure: function () {
      progress.descendants.each(remove);
    }
  });
};

// prepare an element for the spinner
function prepare_spinner() {
  this.style.width = progress_gif.width;
  this.style.height = progress_gif.height;
};

// return a progress spinner image
function spinner() {
  var img = document.createElement('img');
  img.src = progress_gif.src;
  return img;
};

function init() {
  ajaxify_page();
};

Event.observe(window, 'load', init);

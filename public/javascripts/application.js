/*
  Global constants
*/
var ADD_IMAGE_BUTTON = "<a href='javascript:void(0)' class='add_button'>Add an image</a>";

/*
  Global inits
*/
function init_feedback_form () {
  $('#feedback_form').live('ajax:success', function (element, data, status, xhr) {
    if (data.ok) {
      $('#feedback_form_container').html("<div class='success'>Thanks!</div>");
      setTimeout(function () {
        $(document).trigger('close.facebox');
      }, 600);
    } else {
      $('#feedback_form_container .error').html(data.error);
    }
  });
}
function init_login_form () {
  $('#new_user_session').live('ajax:success', function (element, data, status, xhr) {
    if (data.ok) {
      window.location.reload();
    } else {
      alert("Invalid credentials.");
    }
  });
}
function init_register_form () {
  $('#new_user').live('ajax:success', function (element, data, status, xhr) {
    if (data.ok) {
      $('#register_login').html("<div class='success'>Thanks!</div>");
      setTimeout(function () {
        $(document).trigger('close.facebox');
        window.location.reload();
      }, 1000);
    } else {
      var error_list = $('#register_login .register .error');
      error_list.html('');
      $(data.errors).each(function (ix, message) {
        error_list.append($("<li></li>").html(message));
      });
    }
  });
}
function init_add_new_menu () {
  $('#add_new').hover(function () {
    var container = $('#add_new_container');
    var sub_menu  = $('#add_new_sub_menu');
    sub_menu.slideDown(400);
    container.addClass("open");
  },
  function () {
    var container = $('#add_new_container');
    var sub_menu  = $('#add_new_sub_menu');
    sub_menu.delay(1500).slideUp(400);
    container.removeClass("open");
  });
}
function init_category_autocomplete (collection_id) {
  $('#category_field').autocomplete({
    source    : "/collection/" + collection_id + "/category_autocomplete",
    minLength : 1
  });
}
function init_add_to_collection () {
  $('#add_to_collection_button').live("click", function () {
    if ($('#category_field').val().match(/^\s*$/)) {
      $('#category_field').css({ border : '1px solid red'});
      return false;
    }
    $.ajax({
      url     : $('.add_to_collection form').attr("action"),
      type    : 'POST',
      data    : { 'collection' : $('#collection_select').val(), 'category' : $('#category_field').val() },
      success : function (data, textStatus, jqXHR) {
        if (data.ok) {
          $('.add_to_collection').html("<div class='success'>Success!</div>");
          setTimeout(function () {
            // For a new protocol, redirect to the view page, but for an
            // existing one, just close the facebox.
            if (window.location.pathname == "/protocols/new") {
              window.location.href = "/protocol/" + data.protocol_id;
            } else {
              $(document).trigger('close.facebox');
            }
          }, 600);
        } else {
          alert(data.error);
        }
      }
    });
    return false;
  });
  $('#collection_select').live("change", function () {
    var collection_id = $(this).val();
    init_category_autocomplete(collection_id);
  });
}
function init_search () {
  var default_text = 'protocols, collections...';
  $("#search_field").bind('focus', function () {
    if ($(this).val() == default_text) {
      $(this).removeClass("empty");
      $(this).val('');
    }
  });
  $("#search_field").bind('blur', function () {
    if ($(this).val().match(/^\s*$/)) {
      $(this).addClass("empty");
      $(this).val(default_text);
    }
  });
}
$(document).ready(function () {
  $('#register').facebox();
  $('#login').facebox();
  $('#feedback a').facebox();

  init_feedback_form();
  init_login_form();
  init_register_form();
  init_add_new_menu();
  init_add_to_collection();
});

/*
  Global utilities
*/
var CKEDITOR_DEFAULT_STYLE = {
  skin : "kama",
  toolbar : "Basic",
  toolbar_Basic : [['Bold', 'Italic', '-', 'Link', 'Unlink']],
  width:'100%'
};
CKEDITOR.config.forcePasteAsPlainText = true;
/*
  Turn all elements into CKEditors.
*/
function init_ckeditor (elements) {
  $(elements).each(function (ix, textarea) {
    $(textarea).ckeditor(function () {}, CKEDITOR_DEFAULT_STYLE);
  });
}

var UPLOAD_FAILED_MESSAGE = "<span class='error'>Upload failed.</span>";
/*
  Turn all elements into image upload buttons.
*/
function init_uploader (elements) {
  $(elements).each(function (ix, upload_button) {
    var uploader = new qq.FileUploaderBasic({
      action     : "/protocols/upload_image",
      multiple   : false,
      button     : upload_button,
      onSubmit   : function (id, filename) {
        var parent = $(this.button).parents('.image');
        var hidden_input = $(parent.find('input[named=image_id]')[0]);
        if (hidden_input) {
          uploader.setParams({
            old_image_id : hidden_input.val()
          });
        }
      },
      onComplete : function (id, filename, response) {
        var image_container = $(upload_button).parents('.image');
        if (response.ok) {
          image_container.html(response.thumbnail_html);
          init_uploader(image_container.find(".change_image")[0]);
        } else {
          var error = $(UPLOAD_FAILED_MESSAGE).delay(2000).fadeOut('slow');
          image_container.append(error);
        }
      }
    });
  });
}
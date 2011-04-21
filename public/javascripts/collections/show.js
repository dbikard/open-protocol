function create_button (value) {
  return $("<input type='submit'></input>").val(value);
}
function create_submit_button () {
  return create_button("Submit");
}
function create_cancel_button () {
  return create_button("Cancel");
}
function create_edit_button (id) {
  return $("<a href='javascript:void(0)' class='edit_button'>Edit</a>").attr("id", id);
}
function create_text_input(name) {
  var input = $("<input type='text'></input>");
  if (name) {
    input.attr("name", name);
  }
  return input;
}

function post_inline_edit(container, attrs, callback) {
  var saving = $("<span class='saving'>Saving...</span>");
  $.ajax({
    url     : window.location.pathname + "/inline_edit",
    type    : 'POST',
    data    : attrs,
    beforeSend : function () {
      saving.fadeIn(500);
      container.append(saving);
    },
    success : function (data, textStatus, jqXHR) {
      if (data.ok) {
        callback(data);
      } else {
        alert(data.error);
      }
    },
    error : function () {
      alert("Save failed.");
    },
    complete : function () {
      saving.fadeOut(500);
    }
  });
}

$(document).ready(function () {
  $('#delete_link').facebox();
  $('#delete_confirm').live("click", function () {
    if ($('#delete_field').val().toUpperCase() == "DELETE") {
      return true;
    } else {
      $('#delete_field').css({ border : "1px solid red"});
      return false;
    }
  });

  $('.category ul li .remove_button').live("click", function () {
    var link = $(this);
    if (!confirm("Are you sure you want to remove this protocol from your collection?")) {
      return false;
    }
    $.ajax({
      url     : link.attr('href'),
      type    : 'POST',
      success : function (data, textStatus, jqXHR) {
        if (data.ok) {
          var list = link.parents("ul");
          link.parents("li").remove();
          if (list.find("li").length == 0) {
            list.parents(".category").remove();
          }
        } else {
          alert(data.error);
        }
      }
    });
    return false;
  });

  $('#contact_edit').live('click', function () {
    var edit   = $(this);
    var submit = create_submit_button();
    var cancel = create_cancel_button();

    var original_html = $("#contact").html();

    var span = $("#contact .text");
    var original_value = span.html().trim();

    var input = create_text_input("");
    input.val(original_value);
    span.replaceWith(input);
    input.after(cancel).after(submit);
    edit.hide();

    cancel.click(function () {
      $("#contact").html(original_html);
      edit.show();
    });
    submit.click(function () {
      var new_contact = input.val();
      post_inline_edit(span, { 'contact' : new_contact }, function () {
        $("#contact").html(original_html);
        $('#contact .text').html(new_contact);
        edit.show();
      });
    });
  });

  $('#homepage_edit').live('click', function () {
    var edit   = $(this);
    var submit = create_submit_button();
    var cancel = create_cancel_button();

    var original_html = $("#homepage").html();

    var link = $("#homepage_link");
    var original_value = link.attr("href").trim();

    var input = create_text_input("");
    input.val(original_value);
    link.replaceWith(input);
    input.after(cancel).after(submit);
    edit.hide();

    cancel.click(function () {
      $("#homepage").html(original_html);
      edit.show();
    });
    submit.click(function () {
      var new_homepage = input.val();
      post_inline_edit($('#homepage'), { 'homepage' : new_homepage }, function () {
        $("#homepage").html(original_html);
        $('#homepage_link').html(new_homepage).attr("href", new_homepage);
        edit.show();
      });
    });
  });

  $('#description_edit').live('click', function () {
    var edit   = $(this);
    var submit = create_submit_button();
    var cancel = create_cancel_button();

    var original_html = $("#description").html();
    var div = $("#description .text");
    var original_value = div.html().trim();

    var textarea = $("<textarea rows='10'></textarea>");
    div.replaceWith(textarea);
    init_ckeditor(textarea);
    var editor = textarea.ckeditorGet();
    textarea.val(original_value);
    $("#description").append(submit).append(cancel);
    edit.hide();
    cancel.click(function () {
      $("#description").html(original_html);
    });
    submit.click(function () {
      var new_description = textarea.val();
      post_inline_edit($('#description'), { 'description' : new_description }, function () {
        $("#description").html(original_html);
        $("#description .text").html(new_description);
      });
    });
  });

  var last_shown = null;
  $('.category li').live({
    mouseenter : function () {
      var button = $(this).find('a.remove_button');
      if (last_shown && (button !== last_shown)) {
        last_shown.stop(true,false);
        last_shown.hide();
      }
      last_shown = button;
      button.show();
    },
    mouseleave: function () {
      var button = $(this).find('a.remove_button');
      button.delay(400).fadeOut(200);
    }
  });

  $('.category h3 .edit_button').live('click', function () {
    var edit   = $(this);
    var category = edit.parents(".category");
    var submit = create_submit_button();
    var cancel = create_cancel_button();

    var original_html = category.html();

    var span = category.find("h3 span");
    var original_value = span.html().trim();

    var input = create_text_input("");
    input.val(original_value);
    span.replaceWith(input);
    input.after(cancel).after(submit);
    edit.hide();

    cancel.click(function () {
      category.html(original_html);
    });
    submit.click(function () {
      var new_name = input.val();
      $.ajax({
        url     : '/collections/rename_category',
        type    : 'POST',
        data    : { 'category_id' : edit.attr("id"), 'name' : new_name },
        success : function (data, textStatus, jqXHR) {
          if (data.ok) {
            category.html(original_html);
            category.find("h3 span").html(new_name);
          } else {
            alert(data.error);
          }
        }
      });
    });
    return false;
  });
});
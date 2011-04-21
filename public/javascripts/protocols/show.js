/*
  Utilities
*/
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
function parse_time (times_string) {
  var times = times_string.match(/((\d+) hr)?\s*((\d+) min)?\s*((\d+) sec)?/);
  var hours = parseInt(times[2] || 0);
  var minutes = parseInt(times[4] || 0);
  var seconds = parseInt(times[6] || 0);
  return [hours, minutes, seconds];
}
function format_time (container, hours, minutes, seconds) {
  container.html("");
  if (parseInt(hours || 0) > 0) {
    container.append(hours).append(" hr ");
  }
  if (parseInt(minutes || 0) > 0) {
    container.append(minutes).append(" min ");
  }
  if (parseInt(seconds || 0) > 0) {
    container.append(seconds).append(" sec");
  }
}
function recalculate_total_time () {
  var hours = 0;
  var minutes = 0;
  var seconds = 0;
  $('#steps .times').each(function (ix,el) {
    var times = parse_time($(el).html().trim());
    hours += times[0];
    minutes += times[1];
    seconds += times[2];
  });
  minutes += Math.floor(seconds / 60);
  seconds = seconds % 60;
  hours += Math.floor(minutes / 60);
  minutes = minutes % 60;
  format_time($('#introduction .times'), hours, minutes, seconds);
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

/*
  Step editing
*/

var NEW_STEP_HTML = "<li>" +
                      "<div class='times'>0 hr 0 min 0 sec</div>" +
                      "<div class='text'>" +
                        "<h2>Step Title</h2>" +
                        "<div class='instructions'></div>" +
                        "<a href='javascript:void(0)' class='step_edit edit_button'>Edit</a>" +
                      "</div>" +
                      "<div class='image'>" +
                      "<a href='javascript:void(0)' class='add_button'>Add an image</a>" +
                      "</div>" +
                    "</li>";
function prepare_step_for_editing (step, is_new) {
  step.addClass("editing");
  var button = step.find(".step_edit");
  button.hide();
  if (!is_new) {
    var add_new_step_button = create_button("Add New Step").click(function () {
      var new_step = $(NEW_STEP_HTML);
      step.after(new_step);
      init_uploader(new_step.find(".image .add_button"));
      prepare_step_for_editing(new_step, true);
    });
  }
  var remove_step_button = create_button("Remove This Step").click(function () {
    if (is_new) {
      step.remove();
      recalculate_total_time();
    } else {
      var step_id = step.find("input[name=step_id]").val();
      if (!confirm("Are you sure you want to remove this step?")) {
        return;
      }
      $.ajax({
        url     : window.location.pathname + "/remove_step",
        type    : 'POST',
        data    : { 'step_id' : step_id },
        success : function (data, textStatus, jqXHR) {
          if (data.ok) {
            step.remove();
            recalculate_total_time();
          } else {
            alert(data.error);
          }
        }
      });
    }
  });
  var submit = create_submit_button();
  var cancel = create_cancel_button();

  var times_container = step.find('.times');
  var times_string    = times_container.html().trim();
  var times           = parse_time(times_string);
  var hours_input     = create_text_input("hours")  .val(times[0]);
  var minutes_input   = create_text_input("minutes").val(times[1]);
  var seconds_input   = create_text_input("seconds").val(times[2]);

  times_container.html("").append(hours_input).append(" hr ").append(minutes_input).append(" min ").append(seconds_input).append(" sec");

  var title = step.find('.text h2').html().trim();
  var instructions = step.find('.text .instructions').html().trim();

  var title_input = create_text_input("title");
  title_input.val(title);
  step.find('.text h2').html(title_input);

  var textarea = $("<textarea rows='10'></textarea>");
  step.find('.text .instructions').replaceWith(textarea);
  init_ckeditor(textarea);
  var editor = textarea.ckeditorGet();
  textarea.val(instructions);
  step.find(".text").append(submit);
  step.find(".text").append(remove_step_button);
  if (!is_new) {
    step.find(".text").append(cancel);
    step.find(".text").append(add_new_step_button);
    cancel.click(function () {
      step.find('.text h2').html(title);
      textarea.replaceWith($("<div class='instructions'></div>").html(instructions));
      times_container.html(times_string);
      editor.destroy();
      cancel.remove();
      submit.remove();
      add_new_step_button.remove();
      remove_step_button.remove();
      button.show();
      step.removeClass("editing");
    });
  }

  submit.click(function () {
    var new_title        = step.find('.text h2 input').val();
    var new_instructions = textarea.val();
    var new_hours        = hours_input.val();
    var new_minutes      = minutes_input.val();
    var new_seconds      = seconds_input.val();

    var step_data = {
      'name' : new_title,
      'instructions' : new_instructions,
      'duration_hours' : new_hours,
      'duration_minutes' : new_minutes,
      'duration_seconds' : new_seconds,
      'image_id'         : step.find('.image input[name=image_id]').val()
    };

    var id = step.find('input[name=step_id]').val();
    if (id) {
      step_data['id'] = id;
    } else {
      anchor_step = step.prevAll("li:has(input[name=step_id])").first();
      anchor_id = anchor_step.find("input[name=step_id]").val();
      step_data['anchor_id'] = anchor_id;
    }

    var saving = $("<span class='saving'>Saving...</span>");
    $.ajax({
      url     : window.location.pathname + "/edit_step",
      type    : 'POST',
      data    : { 'step' : step_data },
      beforeSend : function () {
        saving.fadeIn(500);
        step.find(".text").append(saving);
      },
      success : function (data, textStatus, jqXHR) {
        if (data.ok) {
          editor.destroy();
          step.html(data.step_html);
          recalculate_total_time();
          step.removeClass("editing");
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
  });
}

$(document).ready(function () {
  /*
    Comments
  */
  $('#submit_comment').click(function () {
    var textarea = $('#create_comment textarea');
    if (textarea.val()) {
      $.ajax({
        url     : window.location.pathname + "/create_comment",
        type    : 'POST',
        data    : { comment : textarea.val() },
        success : function (data, textStatus, jqXHR) {
          if (data.ok) {
            var comment = $(data.comment_html).fadeIn('fast');
            $('#comments ul').prepend(comment);
            textarea.val("");
          } else {
            alert(data.error);
          }
        }
      });
    }
  });

  /*
    Title edit
  */
  $('#name_edit').live("click", function () {
    var submit = create_submit_button();
    var cancel = create_cancel_button();

    var original_html = $("#name").html();

    var span = $("#name span");
    var original_value = span.html().trim();
    span.remove();

    var input = create_text_input("name");
    input.val(original_value);

    $('#name').html(input).append(submit).append(cancel);

    cancel.click(function () {
      $("#name").html(original_html);
    });
    submit.click(function () {
      var new_name = input.val();
      post_inline_edit(span, { 'name' : new_name }, function () {
        var new_span = $("<span></span>").html(new_name);
        $("#name").html(new_span);
        new_span.after(create_edit_button('name_edit'));
      });
    });
  });

  /*
    Authors edit
  */
  $('#authors_edit').live("click", function () {
    var submit = create_submit_button();
    var cancel = create_cancel_button();

    var authors_html = $('#authors').html();
    var authors = $('#authors span').map(function (index, author) {
      return $(author).html().trim();
    });
    var ul = $("<ul></ul>").addClass("clearfix");
    $(authors).each(function (index, name) {
      var li = $("<li><label>Name</label></li>");
      var li_input = create_text_input().val(name);
      li.append(li_input);
      ul.append(li);
    });
    var add_button = create_button("Add Author").click(function () {
      ul.append("<li><label>Name</label><input type='text'></input></li>");
    });
    $("#authors").html("By ").append(ul).append(submit).append(cancel).append(add_button);
    cancel.click(function () {
      $('#authors').html(authors_html);
    });
    submit.click(function () {
      var new_authors = $('#authors input[type=text]').map(function (index, author) {
        return $(author).val().trim();
      });
      post_inline_edit($('#authors'), { 'authors' : new_authors.toArray() }, function (data) {
        $('#authors').html(data.authors_html);
      });
    });
  });

  /*
    Intro edit
  */
  $('#introduction_edit').live("click", function () {
    $('#introduction_edit').hide();
    var submit = create_submit_button();
    var cancel = create_cancel_button();

    var container = $('#introduction .text .content');

    var intro = container.html().trim();
    var textarea = $("<textarea rows='10'></textarea>");
    container.replaceWith(textarea);
    init_ckeditor(textarea);
    var editor = textarea.ckeditorGet();
    textarea.val(intro);
    $('#introduction .text').append(submit).append(cancel);

    cancel.click(function () {
      textarea.replaceWith($("<p class='content'></p>").html(intro));
      editor.destroy();
      cancel.remove();
      submit.remove();
      $('#introduction_edit').show();
    });
    submit.click(function () {
      var new_intro = textarea.val().trim();
      post_inline_edit($('#introduction'), { 'introduction' : new_intro }, function () {
        textarea.replaceWith($("<p class='content'></p>").html(new_intro));
        editor.destroy();
        cancel.remove();
        submit.remove();
        $('#introduction_edit').show();
      });
    });
  });

  /*
    Reagents edit
  */
  $('#reagents_edit').live("click", function () {
    $('#reagents_edit').hide();
    $('#reagents').addClass("editing");
    var submit = create_submit_button();
    var cancel = create_cancel_button();
    var reagents_html = $('#reagents').html();
    var reagents = $('#reagents ul li').map(function (index, reagent) {
      reagent = $(reagent);
      var children = reagent.children();
      if (children.length > 0) {
        var link = $(children[0]);
        return { name : link.html(), link : link.attr("href") };
      } else {
        return { name : reagent.html(), link : null };
      }
    });
    var ul = $("#reagents ul");
    ul.html("");
    $(reagents).each(function (index, hash) {
      var li = $("<li></li>");
      var name_input = create_text_input("reagent_name").val(hash.name);
      var link_input = create_text_input("link").val(hash.link);
      li.append(name_input).append(link_input);
      ul.append(li);
    });
    var add_button = $("<a href='javascript:void(0)'></a>").html("Add reagent").click(function () {
      add_button.parent().before("<li><input name='reagent_name' type='text'></input><input name='link' type='text'></input></li>");
    });
    ul.append($("<li></li>").html(add_button));
    ul.after(cancel).after(submit);

    cancel.click(function () {
      $('#reagents').html(reagents_html).removeClass("editing");
      $('#reagents_edit').show();
    });
    submit.click(function () {
      var new_reagents = [];
      $('#reagents ul li').each(function (index, reagent) {
        reagent = $(reagent);
        var name = reagent.find("input[name=reagent_name]").val();
        var link = reagent.find("input[name=link]").val();
        if (name && name.trim().length > 0) {
          new_reagents.push({ 'name' : name, 'link' : link });
        }
      });

      post_inline_edit($('#reagents'), { 'reagents' : new_reagents }, function () {
        ul.html("");
        $(new_reagents).each(function (index, hash) {
          var li = $("<li></li>");
          if (hash.link) {
            var link = $("<a></a>").attr("href", hash.link).html(hash.name);
            li.append(link);
          } else {
            li.html(hash.name);
          }
          ul.append(li);
        });
        cancel.remove();
        submit.remove();
        $('#reagents').removeClass("editing");
        $('#reagents_edit').show();
      });
    });
  });

  $('.step_edit').live("click", function () {
    prepare_step_for_editing($(this).parents("li"), false);
  });

  $('#steps .image .remove_image').live("click", function () {
    var parent = $(this).parents(".image");
    parent.html(ADD_IMAGE_BUTTON);
    var upload_button = parent.find("a");
    init_uploader(upload_button);
  });

  $('#steps .image .add_button').each(function (ix, upload_button) {
    init_uploader(upload_button);
  });
  $('#add_to_my_page a').facebox();
});

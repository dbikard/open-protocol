/*
  Tell server to delete image from S3 bucket.
*/
function delete_image (id) {
  $.ajax({
    url     : "/protocols/remove_image",
    type    : 'POST',
    data    : { image_id : id },
    success : function (data, textStatus, jqXHR) {
      if (!data.ok) {
        alert(data.error);
      }
    }
  });
}

/*
  Serializes full protocol form to JSON.
*/
function protocol_to_dict () {
  return {
    name : $('#title').val(),
    authors : $.makeArray($('.author_row input[type=text]').map(function (ix, element) {
      return { name : $(element).val() };
    })),
    introduction : $('#introduction').val(),
    reagents : $.makeArray($('.reagent_row').map(function (ix, element) {
      return {
        name : $(element).find(".name input").val(),
        link : $(element).find(".link input").val()
      };
    })),
    steps : $.makeArray($('.new_step').map(function (ix, element) {
      return {
        id               : $(element).find(".name input[name=id]").val(),
        name             : $(element).find(".name input").val(),
        instructions     : $(element).find(".text textarea").val(),
        image_id         : $(element).find(".image input[name=image_id]").val(),
        duration_hours   : $(element).find(".time input[name=hours]").val(),
        duration_minutes : $(element).find(".time input[name=minutes]").val(),
        duration_seconds : $(element).find(".time input[name=seconds]").val()
      };
    }))
  };
}

$(document).ready(function () {
  init_ckeditor('textarea');
  init_uploader('.new_step .image .add_button');

  /*
    New step
  */
  $('.new_step .remove_image').live("click", function () {
    var image_container = $(this).parents(".image");
    // Make sure we delete the unused image on the server.
    delete_image(image_container.find("input[name=image_id]").val());
    // Add back the upload button and initialize it.
    var upload_button = $(ADD_IMAGE_BUTTON);
    image_container.html(upload_button);
    init_uploader(upload_button);
  });
  $('.new_step .remove_button').live("click", function () {
    var step = $(this).parents(".new_step");
    var image = step.find("input[name=image_id]").val();
    // Make sure we delete the unused image on the server, if there is one.
    if (image) { delete_image(image); }
    step.remove();
  });
  $('#add_step').bind("ajax:success", function (element, data, status, xhr) {
    var step = $(data).fadeIn('fast');
    $('#add_step').before(step);

    // Set up ckeditor for new textarea
    var textarea = step.find("textarea");
    textarea.attr("id", "instructions_" + ($(".new_step").length + 1));
    init_ckeditor(textarea);
    // Set up Add New Image button.
    init_uploader(step.find(".image .add_button"));
  });

  /*
    New author
  */
  $('#add_author').bind("ajax:success", function (element, data, status, xhr) {
    var author = $(data);
    author.fadeIn('fast');
    $('#add_author').before(author);
  });
  $('.author_row .remove_button').live('click', function () {
    $(this).parents('.author_row').remove();
  });

  /*
    New reagent
  */
  $('#add_reagent').bind("ajax:success", function (element, data, status, xhr) {
    var reagent = $(data);
    reagent.fadeIn('fast');
    $('#add_reagent').before(reagent);
  });
  $('.reagent_row .remove_button').live('click', function () {
    $(this).parents('.reagent_row').remove();
  });

  $('#publish_button').click(function () {
    var protocol = protocol_to_dict();
    if (!protocol.steps || protocol.steps.length == 0) {
      alert("A protocol must have at least one step.");
      return;
    }
    $.ajax({
      url     : "/protocols/create",
      type    : 'POST',
      data    : { 'protocol' : $.toJSON(protocol) },
      success : function (data, textStatus, jqXHR) {
        if (data.ok) {
          $.facebox({ ajax : "/protocol/" + data.id + "/add_to_collection" });
        } else {
          alert(data.error);
        }
      }
    });
  });
});
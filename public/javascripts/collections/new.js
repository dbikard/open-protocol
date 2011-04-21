$(document).ready(function () {
  init_ckeditor('textarea');
  $('#add_admin').click(function () {
    $('#admin_emails').append("<li><div class='remove'><a href='javascript:void(0)' class='remove_button'></a></div><input name='admins[]' type='text'></input></li>");
  });
  $('.remove_button').live('click', function () {
    $(this).parents("li").remove();
  });
  $('#save_collection').click(function () {
    var name = $('input[name=name]').val();
    if (!name || name.match(/^\s+$/)) {
      alert("Collection Name cannot be blank.");
      return false;
    }
    return true;
  });
  $('form').bind("ajax:success", function (element, data, status, xhr) {
    if (data.ok) {
      window.location.href = "/collection/" + data.id;
    } else {
      alert(data.error);
    }
  });
});
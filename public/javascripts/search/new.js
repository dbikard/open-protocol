$(document).ready(function () {
  init_search();

  $("#collections_only").click(function () {
    $('#search_form').attr("action", "/search?collections_only=true");
    $('#search_form').submit();
  });
  $("#protocols_only").click(function () {
    $('#search_form').attr("action", "/search?protocols_only=true");
    $('#search_form').submit();
  });
  $("#all_classes").click(function () {
    $('#search_form').attr("action", "/search");
    $('#search_form').submit();
  });
});
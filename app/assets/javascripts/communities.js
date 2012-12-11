$(user_settings_communities);

function user_settings_communities(){
  var $form = $("#user_communities_form");
  var $check_boxes = $form.find("input[type='checkbox']");
  $check_boxes.change(function(evt){ 
    $form.submit();
  })
}
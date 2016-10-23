$(document).ready( function() {
  if($('#waiting-room').is(':visible')) {
    showEnter();
  }
});

function showEnter() {
  $.ajax({
    url: "/check_crawler",
    type: "GET",
    dataType: "JSON"
  }).done( function(data) {
    if(data) {
      $('#waiting-room').hide();
      $('#please-enter').show();
    } else {
      console.log('not ready yet');
      setTimeout(showEnter, 10000); 
    }
  }).fail( function(data) {
    alert("Something has gone wrong with our polling, please refresh this page periodically");
    console.log(data)
  })
}
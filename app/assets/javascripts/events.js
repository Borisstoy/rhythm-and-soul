$(document).ready(function () {
  var endOfScroll = function (el) {
    var endZoneSize = 10,
        endZone = (el[0].scrollHeight - el.outerHeight() - endZoneSize),
        position = el.scrollTop();
    return (position >= endZone);
  }

  var detector = function () {
    $('#events-list').on('scroll', function () {
      if(endOfScroll($(this))) {
        // prevent multiple event triggers.
        $('#events-list').off('scroll');
        var nextLink = $('.next a');
        nextLink.click() // render new content via AJAX
          .done(detector()); // reset event
      }
    });
  };

  detector();
});

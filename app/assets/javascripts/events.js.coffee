# $(document).ready ->
#   $("#events-list .wrapper-event-description").infinitescroll
#     navSelector: "nav.pagination" # selector for the paged navigation (it will be hidden)
#     nextSelector: "nav.pagination a[rel=next]" # selector for the NEXT link (to page 2)
#     itemSelector: "#events-list .wrapper-event-description" # selector for all items you'll retrieve
#   $(window).scroll()

# # Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use CoffeeScript in this file: http://coffeescript.org/



# # Setup plugin and define optional event callbacks
# $('.infinite-table').infinitePages
#  debug: true
#  buffer: 200 # load new page when within 200px of nav link
#  context: '.pane' # define the scrolling container (defaults to window)
#  loading: ->
#    # jQuery callback on the nav element
#    $(this).text("Loading...")
#  success: ->
#    # called after successful ajax call
#  error: ->
#    # called after failed ajax call
#    $(this).text("Trouble! Please drink some coconut water and click again")

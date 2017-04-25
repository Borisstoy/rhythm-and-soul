# app/assets/javascripts/posts.js.coffee

$(document).ready ->
  $(".events-search .index-events-list #events-list .partial-events").infinitescroll
    navSelector: "nav.pagination" # selector for the paged navigation (it will be hidden)
    nextSelector: "nav.pagination a[rel=next]" # selector for the NEXT link (to page 2)
    itemSelector: ".events-search .index-events-list #events-list .events_elements" # selector for all items you'll retrieve

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

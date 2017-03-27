queryForPercentage = () ->
  job_id = $('#job_id').text() # grabbing the job_id
  console.log 'sending ' + job_id + 'to /percentage_done'
  $.ajax({
    url: "/percentage_done" # sending an ajax request to /percentage_done
    data:
      job_id: job_id # using the job_id from the DOM
    success: (data) -> # The code in the 'success' function will execute after a successful call to the percentage_done controller
      percentage = 'width: ' + data['percentage_done'] + '%;'
      # writing the percentage done to the progress bar
      $('#job-progress').attr('style', percentage).text(data['percentage_done'] + '%')
      console.log(data['percentage_done'])

      # unless the job-progress is 100% I want to recursively call the same function after 1.5 seconds.
      # which resend the request to my percentage_done action
      if $('#job-progress').text() != '100%'
        setTimeout(queryForPercentage, 1500)
  })

  $('#job-id-container').bind('DOMSubtreeModified', queryForPercentage )

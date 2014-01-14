$ ->
  socket = io.connect()
  console.log "loaded"
  rff = -> false
  rndr =->
    $("#myModal").modal "toggle"
    $form = $(this)
    $("#myBar").css "display", "block"
    $("#myImg").css "display", "none"
    # $("#ankt").css "display", "none"
    $("#rndMes").css "display", "none"
    $("#rndst").removeClass "alert-danger"
    $("#rndst").addClass "alert-info"

    $("#dBtn").addClass "disabled"
    socket.emit 'rnder', $form.serialize()
    socket.on 'rnders', (data) ->
      $("#rndst").html data
    socket.on 'rndere', (data) ->
      $("#rndst").removeClass "alert-info"
      $("#rndst").addClass "alert-danger"
      $("#rndst").html data
      $("#myBar").css "display", "none"

    socket.on 'rnderf', (data) ->
      $("#myBar").css "display", "none"
      if data.err?
        $("#rndMes").css "display", "block"
        $("#rndMes").text p.err
      else
        $("#ankt").css "display", "block"
        $("#myImg").css "display", "block"
        $("#myImg").attr "src", data.thumb
        $("#dBtn").removeClass "disabled"
        $("#dBtn").attr "href", "/download/#{data.thumb}"
    false

  $("#anktf").submit ->
    $form = $(this)
    $("#anktf").css "display", "none"
    $("#ankta").html 'ご協力ありがとう御座いました'

    $.post "/ankt", $form.serialize(), ((p) ->
    ), "json"
    false

  $("#thatForm").submit rff
  $("#dataFile").change ->
    $("#thatForm").unbind 'submit'
    $(this).upload "/upp", ((res) ->
      console.log res
      $("#thatSubmit").removeClass "disabled"
      $("#dataPath").val res
      $("#thatForm").submit rndr
    ), "text"


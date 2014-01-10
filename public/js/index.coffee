$ ->
  console.log "loaded"
  rff = -> false
  rndr =->
    $("#myModal").modal "toggle"
    $form = $(this)
    $("#myBar").css "display", "block"
    $("#myImg").css "display", "none"
    # $("#ankt").css "display", "none"
    $("#rndMes").css "display", "none"
    $("#dBtn").addClass "disabled"
    $.post "/rnder", $form.serialize(), ((p) ->
      $("#myBar").css "display", "none"
      if p.err?
        $("#rndMes").css "display", "block"
        $("#rndMes").text p.err
      else
        $("#ankt").css "display", "block"
        $("#myImg").css "display", "block"
        $("#myImg").attr "src", p.thumb
        $("#dBtn").removeClass "disabled"
        $("#dBtn").attr "href", "/download/#{p.thumb}"
    ), "json"
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


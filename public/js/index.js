// Generated by CoffeeScript 1.6.3
$(function() {
  var rff, rndr, socket;
  socket = io.connect();
  console.log("loaded");
  rff = function() {
    return false;
  };
  rndr = function() {
    var $form;
    $("#myModal").modal("toggle");
    $form = $(this);
    $("#myBar").css("display", "block");
    $("#rndst").css("display", "block");
    $("#myImg").css("display", "none");
    $("#rndMes").css("display", "none");
    $("#rndst").removeClass("alert-danger");
    $("#rndst").addClass("alert-info");
    $("#dBtn").addClass("disabled");
    socket.emit('rnder', $form.serialize());
    socket.on('rnders', function(data) {
      return $("#rndst").html(data);
    });
    socket.on('rndere', function(data) {
      console.log("えらーだよっ" + data);
      $("#rndst").removeClass("alert-info");
      $("#rndst").addClass("alert-danger");
      $("#rndst").html(data);
      return $("#myBar").css("display", "none");
    });
    socket.on('rnderf', function(data) {
      $("#myBar").css("display", "none");
      $("#rndst").css("display", "none");
      $("#ankt").css("display", "block");
      $("#myImg").css("display", "block");
      $("#myImg").attr("src", data.thumb);
      $("#dBtn").removeClass("disabled");
      return $("#dBtn").attr("href", "/download/" + data.thumb);
    });
    return false;
  };
  $("#anktf").submit(function() {
    var $form;
    $form = $(this);
    $("#anktf").css("display", "none");
    $("#ankta").html('ご協力ありがとう御座いました');
    $.post("/ankt", $form.serialize(), (function(p) {}), "json");
    return false;
  });
  $("#thatForm").submit(rff);
  return $("#dataFile").change(function() {
    $("#thatForm").unbind('submit');
    return $(this).upload("/upp", (function(res) {
      console.log(res);
      $("#thatSubmit").removeClass("disabled");
      $("#dataPath").val(res);
      return $("#thatForm").submit(rndr);
    }), "text");
  });
});

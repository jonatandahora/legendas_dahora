// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets//sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require semantic-ui
//= require turbolinks
//= require_tree .

$( document ).ready(function() {
$('.ui.dropdown').dropdown({
    transition: 'drop'
})
$('.message .close').on('click', function() {
  return $(this).closest('.message').fadeOut();
});

$( "input[name*='line']" ).keypress(function(e) {

    var input_name = this.name;

    if(e.which == 13) {

        $.ajax({

            method: "POST",
            url: "/translation/edit_line",
            data: { sequence: this.name.substr(5,1), text_index: this.name.substr(8,1), text: $(this).val() }
        })
        .success(function( msg ) {

            alert( "Linha Revisada!" );
            $("input[name='"+input_name+"']").siblings().addClass('green');
            $("input[name='"+input_name+"']").siblings().children().removeClass('question');
            $("input[name='"+input_name+"']").siblings().children().addClass('check');
        })
        .error(function(msg){

            alert("Não foi possível salvar a linha: " + msg);
        });
    }
});


$("#plus_one").click(function (e) {
    $.ajax({

        method: "POST",
        url: "/translation/sync_all",
        data: { time: "+1.0s" }
    })
    .success(function( msg ) {
        window.location.reload(true);
    })
});

$("#minus_one").click(function (e) {
    $.ajax({

        method: "POST",
        url: "/translation/sync_all",
        data: { time: "-1.0s" }
    })
    .success(function( msg ) {
        window.location.reload(true);
    })
});

});

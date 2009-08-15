$(function() {
    $(".edit_translation").click(function(e) {
        e.preventDefault();
        key = $(this).attr("data-key");
        val = $(this).attr("data-value");
        lang = $(this).attr("data-lang"); 

        $(this).fadeOut(function(){
            edit_box = $("<input type='text' name='new_text' value='"+ val +"' />" +
                         "<input type='button' value='save' class='save_edit' data-key='" + key + "' data-lang='"+ lang +"' />");
            $(this).siblings(".translation").replaceWith(edit_box);
        });
    });

    $(".save_edit").live("click", function(e){
        element = $(this);
        key = element.attr("data-key");
        lang = element.attr("data-lang");
        new_value = element.siblings("input").val();

        // Yup, this is slightly dodgy :)
        classes = "translation";
        if (lang == "en")
            classes = classes + " primary";

        $.post("/editor/save_translation", {language: lang, trans_key: key, value: new_value}, function(data, status) {
            if(status == "success") {
                element.fadeOut(function() {
                    element.siblings("input").replaceWith("<span class='"+ classes +"'>" + new_value + "</span>");

                    // Reset the new value...
                    element.siblings(".edit_translation").attr("data-value", new_value).fadeIn();
                });
            }
            else {
                alert("Sorry, something failed - please check the server logs!");
            }
        });
        
    });
});
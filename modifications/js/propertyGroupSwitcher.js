$(document).ready(function() {
    $("ul#profileCats li a").not("a#currentCat").each(function(){
        var groupID = $(this).attr("href");
        $(groupID).hide();
        // alert("Group ID:" + groupID);
        });
    $("ul#profileCats li a").click(function(){
        var activeID = $(this).attr("href");
        // alert("Active ID:" + activeID);
        $("ul#profileCats li a").removeAttr("id").each(function(){
            var groupID = $(this).attr("href");
            $(groupID).hide();
            });
        $(this).attr("id", "currentCat");
        $(activeID).show();
        
        return false;
    });
});

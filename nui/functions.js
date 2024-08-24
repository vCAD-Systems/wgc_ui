var lastSite = "https://copnet.ch";

$(document).ready(function () {
    var tabWrap = $(".tab-wrap");
    let tabContainer = "#tab-container";
    // Show or hide the page
    function HIDE_TAB() {
        $("#tab-container").css("display", "none");
        $("#tab-container-flixxx").css("display", "none");
        window.blur(); // unfocus the window
    }
    HIDE_TAB(); // hide the tablet initial
    // Listens for NUI messages from Lua 
    window.addEventListener('message', function (event) {
        if (event.data.showtab) {
            if (event.data.design) {
                tabContainer = "#tab-container-flixxx";
            } else {
                tabContainer = "#tab-container";

                if (event.data.autoscale == true) {
                    tabWrap
                        .css("width", "65%")
                        .css("max-width", "65%")
                        .css("max-height", "75%")
                        .css("min-height", "75%");
                } else {
                    tabWrap
                        .css("width", "100%")
                        .css("max-width", "100%")
                        .css("max-height", "95%")
                        .css("min-height", "95%");
                }
            }

            if (event.data.site != null) {
                $(tabContainer).find("iframe").attr('src', event.data.site);
                lastSite = event.data.site;
            }

            $(tabContainer).css("display", "flex");
        } else if (event.data.hidetab) {
            HIDE_TAB()
        }
    });
    // When pressed ESC dispatch escape request
    document.addEventListener('keyup', function (data) {
        if (data.which == 27) {
            HIDE_TAB(); // hide ui
            $.post(`http://${GetParentResourceName()}/tablet-bus`, JSON.stringify({
                hide: true
            })) // tell lua to unfocus
        }
    });
    // When clicked the dot
    $('.dot').click(function () {
        if (this.id == 'off') {
            HIDE_TAB(); // hide ui
            $.post(`http://${GetParentResourceName()}/tablet-bus`, JSON.stringify({
                hide: true
            })) // tell lua to unfocus
        } else if (this.id == 'reset') {
            $(tabContainer).find("iframe").attr('src', lastSite);
        }
    });

    // Tell lua the nui loaded
    $.post(`http://${GetParentResourceName()}/tablet-bus`, JSON.stringify({
        load: true
    }))
});

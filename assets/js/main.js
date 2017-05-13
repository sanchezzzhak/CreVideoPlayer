/***
 * Cre Video Player (CreVPlayer)
 */
(function (root, factory) {
    // CommonJS support
    if (typeof exports === 'object') {
        module.exports = factory();
    }
    // AMD
    else if (typeof define === 'function' && define.amd) {
        define(['jquery'], factory);
    }
    // Browser globals
    else {
        factory(root.jQuery);
    }
}(this, function ($) {
    'use strict';
    function CreVPlayer(element,options) {
        this.init();
    }

    CreVPlayer.prototype = {
        constructor: CreVPlayer,
        init: function () {
        }
    };

    // append jquery plugin
    $.fn.CreVPlayer = function (option) {
        var options = typeof option == 'object' && option;
        new CreVideoPlayer(this, options);
        return this;
    };
    $.fn.CreVPlayer.Constructor = CreVPlayer;


}));
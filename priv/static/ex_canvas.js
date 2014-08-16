(function() {
    'use strict';

    var canvas = document.getElementById('canvas');
    var resizeCanvas = function() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    };
    window.addEventListener('resize', resizeCanvas);
    resizeCanvas();

    var ctx = canvas.getContext('2d');
    ctx.font = '2rem sans-serif';

    var evt = new EventSource('/events');
    evt.onmessage = function(e) {
        var opts = JSON.parse(e.data);
        ctx.fillText(opts.text, opts.x, opts.y);
    };

}());

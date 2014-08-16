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
    ctx.fillText('Hello world', 50, 50);

    var evt = new EventSource('/events');
    evt.onmessage = function(e) {
        var x = Math.random() * canvas.width;
        var y = Math.random() * canvas.height;
        ctx.fillText(e.data, x, y);
    };

}());

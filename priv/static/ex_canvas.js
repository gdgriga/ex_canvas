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

}());

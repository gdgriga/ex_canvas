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
        var msg = JSON.parse(e.data);
        draw(msg[0], msg[1] || []);
    };

    var commands = {};
    var draw = function(type, opts) {
        var command = commands[type];
        if (command != null) {
            command.apply(null, opts);
        }
    };

    var DEFAULT_SIZE = 1;
    var DEFAULT_COLOR = '#fff';

    commands.pixel = function(x, y, color) {
        commands.line(x, y, x + 1, y + 1, 1, color, 'round');
    };

    commands.line = function(x1, y1, x2, y2, size, color) {
        ctx.lineWidth = size || DEFAULT_SIZE;
        ctx.strokeStyle = color || DEFAULT_COLOR;
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.stroke();
    };

    commands.text = function(x, y, text, color) {
        ctx.fillStyle = color || DEFAULT_COLOR;
        ctx.fillText(text, x, y);
    };

    var refresh = 10;
    var current = 0;
    window.setInterval(function() {
        if (++current === refresh) {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            current = 0;
        } else {
            ctx.clearRect(0, 0, 50, 50);
            commands.text(20, 45, refresh - current, '#fff');
        }
    }, 1000);

}());

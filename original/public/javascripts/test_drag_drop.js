// うごかない

var offsetX;
var offsetY;
var startX;
var startY;
var target = null;

function mouseDown(e) {
    target = this;
    if (e) {
        startX = e.pageX;
        startY = e.pageY;
    } else if (event) {
        startX = event.clientX + document.body.scrollLeft;
        startY = event.clientY + document.body.scrollTop;
    }
    return false;
}

function mouseMove(e) {
    var x;
    var y;
    if (!target) {
        return true;
    }
    if (e) {
        x = e.pageX;
        y = e.pageY;
    } else if (event) {
        x = event.clientX + document.body.scrollLeft;
        y = event.clientY + document.body.scrollTop;
    }
    x -= offsetX;
    y -= offsetY;
    target.style.position = "absolute";
    target.style.left = x;
    target.style.top = y;
    return false;
}

function mouseUp(e) {
    if (!target) {
        return true;
    }
    var endX;
    var endY;
    if (e) {
        endX = e.pageX;
        endY = e.pageY;
    } else {
        endX = event.clientX + document.body.scrollLeft;
        endY = event.clientY + document.body.scrollTop;
    }
    target.style.width = parseInt(target.style.width.match(/\d+/), 10) + endX - startX;
    target.style.height = parseInt(target.style.height.match(/\d+/), 10) + endY - startY;
    target = null;
}


function setHandler() {
    var elem = $("table");
    elem.style.cursor = "nw-resize";
    elem.onmousedown = mouseDown;
    document.onmouseup = mouseUp;
    document.onmousemove = mouseMove;
}

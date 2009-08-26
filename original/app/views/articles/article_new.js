(function() {
    var selected_text = '';
    function main() {
        selected_text = getSelectedText(window);
        if (!selected_text) {
            selected_text = traceFrames();
        }
        selected_text = selected_text.toString();
        if (selected_text.length >= 1) {
            selected_text = '以下、サイトより抜粋──\n\n' + selected_text;
        }
        // URLは & を含むためエンコードが必要
window.open('<%= server_url_for :controller => "articles", :action => "new" %>?subject=' + encodeURIComponent(document.title) + '&amp;url=' + encodeURIComponent(location.href) + '&amp;body=' + encodeURIComponent(selected_text), '_blank');
    }
    function traceFrames() {
        var flen = window.frames.length;
        for (var i = 0; i < flen; i++) {
            selected_text += getSelectedText(window[i]);
        }
        return selected_text;
    }
    function getSelectedText(win) {
        try {
            if (win.document.selection) {
                return win.document.selection.createRange().text;
            } else {
                return win.getSelection();
            }
        } catch(e) {
            return '';
        }
    }
    main();
})();

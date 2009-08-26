// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// http://www.mozilla.org/projects/search/technical.html

// 検索プラグインを追加できるか？
function search_plugin_add_check() {
    return (typeof window.sidebar == "object") && (typeof window.sidebar.addSearchEngine == "function");
}

// 検索プラグインの追加
// window.sidebar.addSearchEngine でダイアログがでる。
// 戻値を return させたはものの、常に undefined が返ってくるため、
// 実際に登録できたのか、キャンセルしたのかは判別不能。
function search_plugin_add(engine_url, icon_url, engine_name, category_name) {
    if (!search_plugin_add_check()) {
        alert("このブラウザには対応していません。");
        return;
    }
    return window.sidebar.addSearchEngine(engine_url, icon_url, engine_name, category_name);
}

// FireBugのコンソールエリアにログを出力
//
// Example:
//  printfire("foo", "bar", 100);
//
function printfire() {
    if (document.createEvent) {
        printfire.args = arguments;
        var ev = document.createEvent("Events");
        ev.initEvent("printfire", false, true);
        dispatchEvent(ev);
    }
}

// tags配列に対して指定のタグを追加する。
// すでにタグがある場合はそれを消す。
function __tag_toggle(tags, tag_name) {
    var tags_str = null;
    var find_index = null;
    tags.each(function(value, index) {
            if (value.toLowerCase() == tag_name.toLowerCase()) {
                find_index = index;
                throw $break;
            }
        });
    if (find_index == null) {
        tags.push(tag_name);
    } else {
        tags[find_index] = null;
        tags = tags.compact();
    }
    if (tags.length == 0) {
        tags_str = "";
    } else {
        tags_str = tags.join(" ") + " ";
    }
    return tags_str;
}

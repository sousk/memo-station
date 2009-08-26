;;; emacs-memo-station.el --- メモステモード

;; Copyright (C) 2002,2006  Free Software Foundation, Inc.

;; Author: Akira Ikeda <ikeda@dream.big.or.jp>
;; Keywords: program text

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; $Id: emacs-memo-station.el 558 2006-03-15 16:57:03Z ikeda $

;; 設定方法
;;
;; (require 'memo-station)
;;

;;; Code:

(defgroup memo-station nil
  "*メモステモード"
  :prefix "memo-station-"
  :group 'data)

(defcustom memo-station-separator-regexp "^-+$"
  "*メモステのセパレーターの正規表現"
  :type 'regexp
  :group 'memo-station)

(defcustom memo-station-separator-string (make-string 80 ?-)
  "*メモステのセパレーターの文字列"
  :type 'string
  :group 'memo-station)

(defcustom memo-station-bubble-flag t
  "*選択すると同時に一番上に移動させるか？"
  :type 'boolean
  :group 'memo-station)

(defvar memo-station-directory "~/memo-station"
  "メモステファイルの保存ディレクトリ")

(defvar memo-station-url "http://127.0.0.1:3000/"
  "*GET/POSTするURL")

(defvar memo-station-from "ikeda"
  "*メモを作成するときのデフォルトユーザー")

(defvar memo-station-auth-user nil
  "*BASIC認証のユーザー名")

(defvar memo-station-auth-password nil
  "*BASIC認証のパスワード")

;; 以下は内部で使う変数

(defvar memo-station-stack ()
  "メモステの整理用スタック")
(defvar memo-station-save-window nil
  "起動前のウィンドウの状態保存用")
(defvar memo-station-file nil
  "現在使われているメモステファイル")
(defvar memo-station-mode-hook nil
  "メモステ表示モード開始時のフック")
(defvar memo-station-exit-hook nil
  "メモステ表示モード終了時のフック")
(defvar memo-station-edit-mode-hook nil
  "編集用モード時のフック")
(defvar memo-station-edit-save-buffer-hook nil
  "編集用モードでファイル保存した時のフック")
(defvar memo-station-edit-save-buffer-hook nil
  "編集用モードでファイル保存した時のフック")
(defvar memo-station-before-buffer nil
  "メモステモードを起動したバッファ")

(defvar memo-station-mode-map nil
  "メモステ表示参照モードでのキーマップ")
;; (setq memo-station-mode-map nil)
(unless memo-station-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map)
    (define-key map "n" 'memo-station-next)
    (define-key map "p" 'memo-station-previous)
    (define-key map " " 'scroll-up)
    (define-key map "q" 'memo-station-exit)
    (define-key map "\C-m" 'memo-station-copy-and-exit-insert)
    (define-key map "x" 'memo-station-copy-and-exit-execute)
    (define-key map "t" 'memo-station-goto-segment)
    (define-key map "w" 'memo-station-copy-to-kill-ring)
    (define-key map "e" 'memo-station-edit-mode)
    (define-key map "<" 'memo-station-goto-first)
    (define-key map ">" 'memo-station-goto-last)
    (define-key map "d" 'memo-station-delete-push)
    (define-key map "y" 'memo-station-yank-pop)
    (define-key map "?" 'describe-mode)
    (define-key map "j" 'memo-station-scroll-up)
    (define-key map "k" 'memo-station-scroll-down)
    (define-key map "!" 'memo-station-copy-and-exit-execute-minibuffer)
    (setq memo-station-mode-map map)))

(defvar memo-station-edit-mode-map nil
  "メモステ表示参照モードでのキーマップ")
(unless memo-station-edit-mode-map
  (let ((map (copy-keymap text-mode-map)))
    (define-key map "\C-c\C-c" 'memo-station-edit-save-buffer)
    (substitute-key-definition 'save-buffer 'memo-station-edit-save-buffer map global-map)
    (setq memo-station-edit-mode-map map)))

(defvar memo-station-overlays nil)
(defvar memo-station-underline-overlays nil)
(defface memo-station-separator-face
  '((((class color)
      (background dark))
     (:background "red" :bold t :foreground "blue"))
    (((class color)
      (background light))
     (:bold t :foreground "red"))
    (t
     ()))
  "セパレータ用Face")

(defun memo-station-color ()
  "*Highlight the file buffer"
  (interactive)
  (save-excursion
    (let (ov)
      (goto-char (point-min))
      (while (re-search-forward memo-station-separator-regexp nil t)
        (setq ov (make-overlay (match-beginning 0) (match-end 0)))
        (overlay-put ov 'face 'memo-station-separator-face)
        (overlay-put ov 'priority 0)
        (setq memo-station-overlays (cons ov memo-station-overlays))
        (make-local-hook 'after-change-functions)
        (remove-hook 'after-change-functions 'memo-station-remove-overlays)))))

(defun memo-station-remove-overlays (&optional beg end length)
  (interactive)
  (if (and beg end (= beg end))
      ()
    (while memo-station-overlays
      (delete-overlay (car memo-station-overlays))
      (setq memo-station-overlays (cdr memo-station-overlays)))))

(defun memo-station ()
  "メモステ起動
リュージョンが有効なら先頭に追加する
キーバインド \\[memo-station]"
  (interactive)
  (if (eq major-mode 'memo-station-mode)
      (error "メモステモードの中からメモステモードは起動できません。"))
  (setq memo-station-before-buffer (current-buffer))
  (setq memo-station-save-window (current-window-configuration))
  (when memo-station-file
    (if mark-active
        (progn
          (memo-station-append (region-beginning) (region-end))
          (setq mark-active nil))
      (memo-station-view))))

(defun memo-station-view ()
  "メモステファイル表示"
  (interactive)
  (find-file-read-only memo-station-file)
  (delete-other-windows)
  (memo-station-mode)
  (memo-station-goto-first))

(defun memo-station-append (start end)
  "選択部分をメモステファイルの先頭に追加"
  (interactive "r")
  (save-window-excursion
    (let ((str (buffer-substring-no-properties start end)))
      (set-buffer (find-file-noselect memo-station-file))
      (let ((buffer-read-only nil))
        (memo-station-goto-first)
        (insert memo-station-separator-string "\n" str)
        (unless (bolp)
          (insert "\n"))
        (save-buffer)
        (kill-buffer nil)))))

(defun memo-station-next ()
  "次のデータに移動"
  (interactive)
  (when (memo-station-next-exist-p)
    (forward-line)
    (when (search-forward-regexp memo-station-separator-regexp nil t)
      (beginning-of-line)
      (recenter 0))))

(defun memo-station-next-exist-p ()
  "次のデータが存在するか調べる"
  (interactive)
  (save-excursion
    (forward-line)
    (search-forward-regexp memo-station-separator-regexp nil t)))

(defun memo-station-previous ()
  "前のデータに移動"
  (interactive)
  (when (search-backward-regexp memo-station-separator-regexp nil t)
    ;; (forward-line)
    (recenter 0)
    ))

(defun memo-station-exit ()
  "メモステ終了"
  (interactive)
  (memo-station-remove-overlays)
  (kill-buffer nil)
  (set-window-configuration memo-station-save-window)
  (run-hooks 'memo-station-exit-hook))

(defun memo-station-copy-to-kill-ring ()
  "カレントのデータをキルリングにコピー"
  (interactive)
  (let ((data (memo-station-http-get-data)))
    (kill-new data)
    (message "copy %d chars" (length data))
    data))

(defun memo-station-http-get-data ()
  "カレントのデータを取得"
  (interactive)
  (let (start end)
    (memo-station-goto-segment)
    (forward-line)
    (setq start (point))
    (memo-station-next)
    (setq end (1- (point)))             ;-1は最後の改行を取るため
    (memo-station-previous)
    (buffer-substring-no-properties start end)))

(defun memo-station-goto-segment ()
  "カレントデータの先頭にカーソルを移動"
  (interactive)
  (if (not (looking-at memo-station-separator-regexp))
      (memo-station-previous)))

(defun memo-station-goto-first ()
  "先頭のデータにジャンプ"
  (interactive)
  (goto-char (point-min))
  (memo-station-next)
  (memo-station-previous))

(defun memo-station-goto-last ()
  "最後のデータにジャンプ"
  (interactive)
  (goto-char (point-max))
  (memo-station-goto-segment)
  (memo-station-previous))

(defun memo-station-delete-push ()
  "カレントのデータを削除"
  (interactive)
  (let (start end)
    (memo-station-goto-segment)
    (setq start (point))
    (memo-station-next)
    (setq end (point))
    (setq memo-station-stack (cons (buffer-substring-no-properties start end) memo-station-stack))
    (let ((buffer-read-only nil))
      (delete-region start end)
      )
    ;; (save-buffer)
    (message "delete %d chars" (- end start))))

(defun memo-station-yank-pop ()
  "データをヤンク"
  (interactive)
  (when memo-station-stack
    (memo-station-goto-segment)
    (save-excursion
      (let ((buffer-read-only nil))
        (insert (car memo-station-stack))
        ))
    ;; (save-buffer)
    (message "yank %d chars" (length (car memo-station-stack)))
    (setq memo-station-stack (cdr memo-station-stack))))

(defun memo-station-copy-and-exit ()
  "データをキルリングにコピーして終了"
  (interactive)
  (memo-station-copy-to-kill-ring)
  (when memo-station-bubble-flag
    (memo-station-delete-push)
    (memo-station-goto-first)
    (memo-station-yank-pop)
    (save-buffer))
  (memo-station-exit))

(defun memo-station-copy-and-exit-insert ()
  "データをキルリングにコピーして終了してペースト"
  (interactive)
  (memo-station-copy-and-exit)
  (memo-station-insert))

(defun memo-station-copy-and-exit-execute ()
  "データをキルリングにコピーして終了して実行"
  (interactive)
  (memo-station-copy-and-exit)
  (memo-station-insert-to-shell-prompt))

(defun memo-station-insert-to-shell-prompt ()
  "shellのプロンプトにメモステする"
  (let ((dir default-directory))        ;dir=メモステモードを起動したバッファのディレクトリ
    (switch-to-buffer (shell))
    (end-of-buffer)
    (if (not (eolp))
        (kill-line))
    (when (not (string= (expand-file-name dir) (expand-file-name default-directory)))
      (cd dir))
    (memo-station-insert)))

(defun memo-station-insert ()
  "現在のバッファにメモステする"
  (insert (car kill-ring)))

(defun memo-station-scroll-up (arg)
  "ARG 行上スクロール"
  (interactive "p")
  (memo-station-scroll-down (- arg)))

(defun memo-station-scroll-down (arg)
  "ARG 行下スクロール"
  (interactive "p")
  (scroll-down arg))

(defun memo-station-copy-and-exit-execute-minibuffer ()
  "メモステモードを起動したバッファのカレントディレクトリでコマンドを実行する"
  (interactive)
  (memo-station-copy-and-exit)
  (if (get-buffer "*Shell Command Output*")
      (kill-buffer "*Shell Command Output*"))
  (shell-command (read-string (format "%s> " default-directory) (car kill-ring)))
  (pop-to-buffer "*Shell Command Output*")
  (compilation-mode))

(defun memo-station-mode ()
  "\\{memo-station-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'memo-station-mode)
  (setq mode-name "メモステモード")
  (use-local-map memo-station-mode-map)
  (memo-station-color)
  (setq buffer-read-only t)
  (run-hooks 'memo-station-mode-hook))

(defun memo-station-edit-save-buffer ()
  "メモステファイル保存"
  (interactive)
  (let (result)
    (if nil
        (setq result (shell-command-on-region (point-min) (point-max) "~/src/memo_station/script/runner 'Article.text_post(STDIN.read).display'" nil))
      (setq result (memo-station-http-fetch (concat memo-station-url "articles/text_post") 'post (list (cons "content" (http-url-hexify-string (buffer-string) 'utf-8)))))
      )
    (memo-station-mode)
    (memo-station-goto-segment)
    (message "%s" result)
    ))

(defun memo-station-edit-mode ()
  "\\{memo-station-edit-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'memo-station-edit-mode)
  (setq mode-name "メモステ編集モード")
  (use-local-map memo-station-edit-mode-map)
  (setq buffer-read-only nil)
  (run-hooks 'memo-station-edit-mode-hook))

(defun memo-station-get-select-str ()
  (if mark-active
      (prog1
          (buffer-substring-no-properties (region-beginning) (region-end))
        (setq mark-active nil))
    )
  )

(defun memo-station-create ()
  (interactive)
  (let ((buffname "*新規メモ*")
        (select-str (memo-station-get-select-str)))
    (when (get-buffer buffname)
      (kill-buffer buffname))
    (switch-to-buffer buffname)
    (insert "Subject: \n"
            "Url: \n"
            "From: " memo-station-from "\n"
            "Tag: \n"
            "--text follows this line--\n"
            (or select-str "")
            )
    (when t
      ;; 「Subject:」の直後にカーソル移動
      (beginning-of-buffer)
      (move-end-of-line 1)
      )
    (memo-station-edit-mode)
  ))

(defun memo-station-search (&optional tag)
  (interactive)
  (let ((buffname "*検索結果*")
        tag content)
    (setq tag (or tag
                  (read-string "タグ検索: ")))
;;     (if (string= tag "")
;;         (progn
;;           (setq content (memo-station-http-fetch "http://127.0.0.1:3000/articles/text_get" 'get (list (cons "query" tag))))
;;           )
;;       )
    ;; 英単語であれば問題ないが、日本語のタグだと http-url-hexify-string を通さないと正確に渡せない。
    (setq content (memo-station-http-fetch (concat memo-station-url "articles/text_get") 'get (list (cons "query" (http-url-hexify-string tag 'utf-8)))))
    (setq memo-station-before-buffer (current-buffer))
    (setq memo-station-save-window (current-window-configuration))
    (when (get-buffer buffname)
      (kill-buffer buffname))
    (switch-to-buffer buffname)
    (insert content)
    (goto-char (point-min))
    (memo-station-mode)
  ))

(defun memo-station-http-fetch (url method data)
  (interactive)
  (let ((http-fetch-terminator "-- content end --")
        (access_result_buffer nil)
        (default-process-coding-system '(utf-8 . utf-8)) ; LANG=ja_JP.eucJP の環境でも文字化けしないようにするため。
        (content nil)
        )
    (setq access_result_buffer (http-fetch url method memo-station-auth-user memo-station-auth-password data))
    (setq content (save-current-buffer
                      (set-buffer access_result_buffer)
                      ;; FIXME: http経由で取り出すと文字化けした状態で UTF-8 が来る。
                      ;; よくわからないけど nkf -w するとよ読める UTF-8 になる。
                      (shell-command-on-region (point-min) (point-max) "nkf -w -d" (current-buffer) t) ;REPLACEをtにするとバッファを表示しなくなる。

                      ;; ヘッダを除いた部分のみを取得
                      (buffer-substring
                       (progn
                         (goto-char (point-min))
                         (re-search-forward "\n\n" nil t)
                         (point))
                       (progn
                         (goto-char (point-min))
                         (re-search-forward (regexp-quote http-fetch-terminator) nil t)
                         (move-to-column 0)
                         (point)))

                      ))
    content
    ))

(provide 'memo-station)
;;; memo-station.el ends here

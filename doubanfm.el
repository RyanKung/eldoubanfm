;;Installation:
;;In .emacs add:
;;(require 'doubanfm)

(dolist (path-list (list "./lib/"
                         "./lib/http-emacs"
                         "./lib/emms-3.0"))
  (add-to-list 'load-path
               (expand-file-name path-list (file-name-directory load-file-name))))
(require 'emms-setup)
(require 'http-get)
(require 'json)
(emms-standard)
(emms-default-players)
(defvar playlist_url
  "http://api.douban.com/v2/fm/playlist?type=n&channel=27&app_name=pldoubanfms&version=2&sid=0&apikey=Key0c57daf39b62cfbf250790dad2286f3d")
(defvar length 0)

(defun event (process message)
  (set 'currbuf (buffer-name (current-buffer)))
  (switch-to-buffer "listbuffer")
  (set 'data (buffer-string))
  (switch-to-buffer currbuf)
  (set 'songs (cdr (car (json-read-from-string data))))
  (mapcar (lambda (x) 
            (dolist (slst x)
              (if (string-equal (car slst) "url")
                  (emms-add-url (cdr slst)))
              (if (string-equal (car slst) "length")
                  (set 'length (+ length (cdr slst))))
                )) songs)
  (emms-start))

(defun get-play-list()
  (http-get playlist_url nil 'event nil "listbuffer"))

(defun play-fm ()
  (get-play-list)
  (play-fm)
    (if (equal length 0)
        (print "error:%s" data)
      (sit-for length)
      (play-fm))
    (interactive))

(play-fm)
(provide 'doubanfm)

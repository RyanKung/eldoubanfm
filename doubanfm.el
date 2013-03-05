;; Installation:
;; In .emacs add:
;; (require 'doubanfm)

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
  "http://api.douban.com/v2/fm/playlist?type=n&channel=%s&app_name=pldoubanfms&version=2&sid=0&apikey=Key0c57daf39b62cfbf250790dad2286f3d")
(defvar default-channel 27)
(defvar length 0)

(defun event (process message)
  (parse-data))

(defun parse-data () 
  (set 'currbuf (buffer-name (current-buffer)))
  (switch-to-buffer "songs")
  (set 'data (buffer-string))
  (switch-to-buffer currbuf)
  (set 'data (json-read-from-string data))
  (set 'songs (cdr (car data)))
  (if (equal (safe-length songs) 0)
      (print (format "Api error:%s" data))
      (mapcar (lambda (x)
                (dolist (slst x)
                  (if (string-equal (car slst) "url")
                      (emms-add-url (cdr slst)))
                  (if (string-equal (car slst) "length")
                      (set 'length (+ length (cdr slst))))
                  )) songs)))

(defun get-play-list (&optional channel)
  (http-get
   (format playlist_url channel) nil 'event nil "songs"))

(defun play-fm (&optional channel)
  (unless channel (set 'channel default-channel))
  (get-play-list channel)
    (unless (equal length 0)
      (sit-for length)
      (get-play-list)
      (emms-start))
    (interactive))

(defun play-channel (channel)
  (play-fm channel)
  (interactive))

(provide 'doubanfm)

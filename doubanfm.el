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
(defvar host "http://api.douban.com")
(defvar playlist_url "http://api.douban.com/v2/fm/playlist?type=n&channel=%s&app_name=pldoubanfms&version=2&sid=0&apikey=Key0c57daf39b62cfbf250790dad2286f3d")
(defvar like_song_url (format "%s/v2/fm/like_song" host))
(defvar unlike_song_url (format "%s/v2/fm/unlike_song" host))
(defvar default-channel 27)
(defvar length 0)

(defun event (process message)
  (parse-data))

(defun state (process message)
  nil)

(defun parse-data ()
  (set 'length 0)
  (set 'currbuf (buffer-name (current-buffer)))
  (switch-to-buffer "songs")
  (set 'data (buffer-string))
  (switch-to-buffer currbuf)
  (set 'data (json-read-from-string data))
  (set 'songs (cdr (car data)))
  (if (vectorp songs)
      (mapcar (lambda (x)
                (dolist (slst x)
                  (if (string-equal (car slst) "url")
                      (emms-add-url (cdr slst)))
                  (if (string-equal (car slst) "length")
                      (set 'length (+ length (cdr slst))))
                  )) songs))
  (unless (equal length 0)
    (emms-start)))

(defun get-play-list (&optional channel)
  (http-get
   (format playlist_url channel) nil 'event nil "songs"))

(defun fm-play (&optional channel time)
  (if time (sit-for time))
  (unless channel (set 'channel default-channel))
  (get-play-list channel)
    (unless (equal length 0)
      (sit-for length)
      (play-fm))
    (interactive))

(defun fm-pause(&optional time) 
  (if time (sit-for time))
     (emms-stop)
     (interactive))

(defun fm-continue (&optional time)
  (if time (sit-for time))
   (emms-start)
   (interactive))

(defun fm-next ()
  (emms-next))

(defun fm-play-channel (channel)
  (play-fm channel)
  (interactive))

(defun fm-like ()
  (http-get like_song_url nil 'state)
  (interactive))

(defun fm-un-like ()
  (http-get unlike_song_url nil 'state)
  (interactive))

(provide 'doubanfm)

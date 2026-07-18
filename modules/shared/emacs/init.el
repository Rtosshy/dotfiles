;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

(setq make-backup-files nil)

(setq auto-save-default nil)

(setq auto-save-list-file-prefix nil)

(setq create-lockfiles nil)

(setq display-warning-minimum-level :error)

;; org-mode
(leaf org
  :custom
  (org-directory . "~/org")
  (org-agenda-files . '("~/org"))
  (org-refile-targets . '((org-agenda-files :maxlevel . 1)))
  (org-columns-default-format . "%68ITEM(Task) %6Effort(Effort){:} %6CLOCKSUM(Clock){:}")
  (org-startup-indented . t)
  (org-log-done . time)
  :bind (("C-c t i" . org-clock-in)
         ("C-c t o" . org-clock-out)
         ("C-c t s" . org-set-effort)))

;; タスク管理
(leaf org-agenda
  :require t
  :setq ((org-agenda-custom-commands quote (("x" "Unscheduled Tasks" tags-todo "-SCHEDULED>="<today>"-DEADLINE>="<today>"" nil))))
  :bind (("C-c a" . org-agenda)))

(leaf org-capture :custom (org-capture-templates . '(("t" "Todo Entroy to Inbox" entry (file+headline "~/org/0_inbox.org" "Inbox") "** TODO %?\n")))
  :bind (("C-c c" . org-capture)))

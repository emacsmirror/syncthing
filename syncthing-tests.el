;;; syncthing-tests.el -- tests for syncthing

;;; Code:

(require 'ert)
(require 'syncthing)

(ert-deftest syncthing-run-customize ()
  "Run `customize-variable' on missing API token."
  (let ((called nil)
        (args nil))
    (advice-add 'syncthing--interactive-common
                :override
                (lambda (&rest rest) (setq args rest)))
    (advice-add 'customize-variable
                :override
                (lambda (&rest _) (setq called t)))
    (syncthing)
    (advice-remove 'syncthing--interactive-common
                   (lambda (&rest rest) (setq args rest)))
    (advice-remove 'customize-variable
                   (lambda (&rest _) (setq called t)))
    (should
     (string= (format "%s" args)
         (format "%s"`(,syncthing-default-name ,syncthing-base-url ""))))
    (should called)))

(provide 'syncthing-tests)

;;; syncthing-tests.el ends here

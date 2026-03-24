PRO SET_PLOT_X

;2015-10-15
;JD, written
;
; to set up the X device the way I like it

;HISTORY
;2015-12-16	JD	- changed window # to 31



if (!d.name NE 'X') then begin
  print, ' -!-  Device is was not X, setting it to X...'
  set_plot, 'X'
endif


device, true_color=24
device, retain=2, decomposed=1

!p.background=16777215
!p.color=0
!p.charsize=1.5
window, 31
wdelete, 31
!p.background=16777215
!p.color=0
!p.charsize=1.5

end
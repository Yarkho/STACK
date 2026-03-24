FUNCTION MAPS_MGN, maps, a0=a0, a1=a1, gamma=gamma, h=h, k=k, imp=imp, quiet=quiet


; Produces Multi-Gaussian Normalized (MGN) map out of an input map array

; INPUT
; maps			- map or map array
;
;
; OUTPUT
; out_maps		- mgn maps
;
;
; OPTIONAL INPUT
; (copied this from H. Morgan's MGN_NEW routine)
;
; imin			- input image
; a0			- minimum input value for gamma transform
; a1			- maximum input value for gamma transform
; gamma			- default is 3.5. Used for gamma transform
; h			- optional weighting for combining of gamma-transformed image and MGN image. Default 0.9
; k			- optional contrast stretching of MGN images. Default value 1

;
;
; CALLS
; set_plot_X
; read_idl8_colortable
; .r idl/img_proc/pro/mgn_new.pro

;
; HISTORY
; 2019-01-31		JD		- created; followed some naming conventions from  maps_lrr.pro
;

; some checks
if NOT(valid_map(maps)) then begin
  message, '-!- MAPS_MGN:  NOT A VALID INPUT MAP / MAP ARRAY'
  stop
endif

if not(keyword_set(gamma))	then gamma	= 3.5d
if not(keyword_set(a0))		then a0		= 0d
if not(keyword_set(a1))		then a1		= 9d3
if not(keyword_set(h))		then h		= 0.925
if not(keyword_set(k))		then k		= 1d



out_maps	= maps
NX		= n_elements(maps[0].data[*,0])
NY		= n_elements(maps[0].data[0,*])
NMAPS		= n_elements(maps.id)
out_maps	= rem_tag(out_maps, 'data')
out_maps	= add_tag(out_maps, fltarr(NX, NY, NMAPS), 'data')


for imap=0L, NMAPS-1L, 1L do begin
  mgnimg		= mgn(float(maps[imap].data), a0, a1, gamma=gamma, h=h, k=k)
  out_maps[imap].data	= float(mgnimg)
  if not(keyword_set(quiet)) then print, '% MAPS_MGN:  doing', imap, '   out of', NMAPS, out_maps[imap].odur
endfor


return, out_maps
END
FUNCTION MAPS_fe18, maps94, maps171, maps211, no_nan_corr=no_nan_corr, date=date, inv_degr=inv_degr

; PURPOSE
; calculates the Fe XVIII proxy from AIA 
; using the method of Del Zanna (2013), A&A, 558, A73
;
;
; INPUTS
; maps94	       \
; maps171		- (required) AIA maps in 3 filters
; maps211 	       /
;
; OPTIONAL INPUT
; date			- date of observation (to account for AIA degradation)
; no_nan_corr		- (KEYWORD) disables NAN correction in maps_lrr
; inv_degr		- (KEYWORD) apply inverse degradation [experimental]
;
;
; OUTPUT
; out_maps		- Fe 18 map
; 
; CALLS
; aia_get_response
;
;
; NOTES
; 1. The program assumes that the AIA date are interpolated to a common grid,
;    or at least are coaligned well
;
;
; HISTORY
; 2024-10-03		JD 		- created

aia		= aia_get_response(/area, /dn, /full, version=10)
coeff94		= 1d
coeff171	= 1d/450.
coeff211	= 1d/120.

if keyword_set(date) then begin
  aia_td	= aia_get_response(/area, /dn, /full, version=10, timedepend_date=date, /evenorm)
  degr94	= average(aia_td.a94_full.effarea  /aia.a94_full.effarea)
  degr171	= average(aia_td.a171_full.effarea /aia.a171_full.effarea)
  degr211	= average(aia_td.a211_full.effarea /aia.a211_full.effarea)
  
  if keyword_set(inv_degr) then begin
     ;experimental
    coeff94	= 1d 	  *degr94
    coeff171	= 1d/450. *degr171
    coeff211	= 1d/120. *degr211
  endif else begin
    ;standard case
    coeff94	= 1d 	  /degr94
    coeff171	= 1d/450. /degr171
    coeff211	= 1d/120. /degr211
  endelse
endif



out_maps	= maps94

; add ID_EXT tag
if tag_exist(out_maps, 'id_ext') then begin
  id_extb	= '; '
endif else begin
  id_extb = ''
  out_maps = add_tag(out_maps, id_extb, 'id_ext')
endelse
  

; if (n_elements(maps.id) GT 2) then begin 
;   mean_dt		= mean(deriv((anytim2utc(maps.time)).time))/1d3		; (experimental) time resolution of maps [s]
; endif else begin
;   mean_dt		= (((anytim2utc(maps[1].time)).time) - (((anytim2utc(maps[0].time)).time)) )/1d3
; endelse
; mean_dt_fix	= fix(mean_dt +0.5)

  
id_ext_fe18	= id_extb +'Fe XVIII proxy';+trim(mean_dt_fix*diff) +'-sec ('+trim(string(mean_dt*diff, format='(F7.3)'))+')'



; perform the actual Fe XVIII proxy
for imap=0, n_elements(out_maps.id)-1 do begin

  out_maps[imap].data	= maps94[imap].data *coeff94 -(maps211[imap].data *coeff211) -(maps171[imap].data *coeff171)
  out_maps[imap].id_ext	= out_maps[imap].id_ext + id_ext_fe18
endfor


return, out_maps
END
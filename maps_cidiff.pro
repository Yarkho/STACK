FUNCTION MAPS_CIDIFF, maps, diff, no_nan_corr=no_nan_corr

; PURPOSE
; calculates "combined improved" difference of imaging data  (maps array)
; high-level wrapping routine
;
; INPUTS
; maps			- map array
; diff			- difference in time (number of frames)
;
; OPTIONAL INPUT
; no_nan_corr		- (KEYWORD) disables NAN correction in maps_lrr
;
; OUTPUT
; maps_cidiff		- combined improved difference
; 
; CALLS
; maps_rdiff		- calculates Running Difference
; maps_lrr		- calculates Log Running Ratio
; sng			- sign function
;
;
; NOTES
; 	1. All checks are performed in lower-level routines (maps_rdiff, maps_lrr)
;
;
; HISTORY
; 2024-10-01		JD 		- created
; 2024-10-02		JD		- rounded the time in ID_EXT parentheses to 3 decimal places


out_maps	= maps

maps_rd	 	= maps_rdiff(maps, diff)
maps_lrr	= maps_lrr(  maps, diff, no_nan_corr=no_nan_corr)



; zero out the first #diff maps
; and add ID_EXT tag
out_maps[0:diff-1].data = dblarr(n_elements(maps[0].data[*,0]), n_elements(maps[0].data[0,*]), diff)

if tag_exist(out_maps, 'id_ext') then begin
  id_extb	= '; '
endif else begin
  id_extb = ''
  out_maps = add_tag(out_maps, id_extb, 'id_ext')
endelse
  

if (n_elements(maps.id) GT 2) then begin 
  mean_dt		= mean(deriv((anytim2utc(maps.time)).time))/1d3		; (experimental) time resolution of maps [s]
endif else begin
  mean_dt		= (((anytim2utc(maps[1].time)).time) - (((anytim2utc(maps[0].time)).time)) )/1d3
endelse
mean_dt_fix	= fix(mean_dt +0.5)

  
id_ext_cidiff	= id_extb +'CI DIFF '+trim(mean_dt_fix*diff) +'-sec ('+trim(string(mean_dt*diff, format='(F7.3)'))+')'



; perform the actual CI difference
for imap=diff, n_elements(maps.id)-1 do begin

  out_maps[imap].data	= abs(maps_lrr[imap].data)^0.5  * abs(maps_rd[imap].data)^0.5  * sgn(maps_rd[imap].data)
  out_maps[imap].id_ext	= out_maps[imap].id_ext + id_ext_cidiff
endfor


return, out_maps
END
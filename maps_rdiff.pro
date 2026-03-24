FUNCTION MAPS_RDIFF, maps, diff, 	plot=plot, dir=dir, string_name=string_name, out_dir=out_dir,		$
					boxcar=boxcar, int_sat=int_sat, colortable=colortable, 			$
					wsize=wsize, xsize=xsize, ysize=ysize, xrange=xrange, yrange=yrange

; Produces Running Difference (RD or RDIFF) out of an input map array

; INPUT
; maps			- map array
; diff			- difference (number of time indices)
;
; OUTPUT
; out_maps		- running difference maps
;
; OPTIONAL INPUT/OUTPUT
; PLOT			- (keyword)  Set only if you require plotting, not RDIFF calculation
;
; DIR			- (keyword)  directory where the images will be saved
; int_sat		- (keyword)  saturation level +- for the output images
; boxcar		- (keyword)  smoothing boxcar for the output images
; colortable		- (keyword)  IDL colortable to use. Default is 0
; wsize			- (keyword)  IDL window size 
; xsize, ysize		- (keywords) IDL window sizes, X and Y
;
; out_dir		- (keyword)  String containing directory where the images are saved
;
;
; CALLS
; set_plot_X
; read_idl8_colortable
;
; HISTORY
; 2018-01-18		JD		- created; adapted from maps_lrr.pro
; 2018-01-26		JD		- changed the error messages to include name of the program
;					- added: first #diff maps will have data EQ 0 (no LRR possible to calculate)
; 2018-11-14		JD		- fixed the mean_dt to mean_dt*diff in ID_EXT tag
;
; 2021-11-20		JD		- changed calculation of MEAN_DT tag if only 2 input maps
; 2024-10-02		JD		- rounded the time in ID_EXT parentheses to 3 decimal places
;


; some checks
if NOT(valid_map(maps)) or (n_elements(maps) LT 2) then begin
  message, '-!- MAPS_RDIFF:  NOT A VALID INPUT MAP ARRAY'
  stop
endif

if (diff NE fix(diff)) or (diff LE 0d) then begin
  message, '-!- MAPS_RDIFF: INVALID DIFF PARAMETER'
  stop
endif

if n_elements(maps) LT diff then begin
  message, '-!- MAPS_RDIFF: malformed DIFF input'
  stop
endif

if keyword_set(colortable) then begin 
  if (colortable NE fix(colortable)) or (colortable LE 0) then begin
    message, '-!- MAPS_RDIFF: COLORTABLE not set properly'
    stop
  endif
endif

if keyword_set(dir) then begin
  if not(is_string(dir)) or (n_elements(dir) GT 1) then begin
    message, '-!- MAPS_RDIFF: malformed DIR input'
    stop
  endif
endif

if not(keyword_set(string_name)) then string_name = ''






; prep plotting window

if keyword_set(dir) then begin
  set_plot_X
  device, retain=2, decomposed=0
  !p.background		= 128L
  if keyword_set(wsize) then wdef, 28, wsize
  if keyword_set(xsize) and keyword_set(ysize) then window, 28, xsize=xisze, ysize=ysize
  if not(keyword_set(wsize)) and not(keyword_set(xsize)) and not(keyword_set(ysize)) then wdef, 28, 1000
  
  if keyword_set(colortable) then begin
    if colortable GT 74 then begin
      message, '-!- MAPS_RDIFF: invalid colortable'
      stop
    endif
    if (float(!version.release) LT 8.) then begin
	if (colortable GT 40) and (colortable LE 74) then begin
	  read_idl8_colortable, colortable
	endif else loadct, colortable 
    endif else begin
      loadct, colortable
    endelse
  endif
endif


; variable setup
out_maps	= maps
; zero out the first #diff maps
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

  
id_ext_rdiff	= id_extb +'RDIFF '+trim(mean_dt_fix*diff) +'-sec ('+trim(string(mean_dt*diff, format='(F7.3)'))+')'

;create directory for save of the figures
if keyword_set(dir) then begin
  path		= dir+'/rdiff_'+trim(mean_dt_fix*diff)+'sec_' +strmid(maps[0].id,10,3) +trim(string_name) $
		  +'_sat'+trim(int_sat)+'_boxcar'+ trim(boxcar)
  file_mkdir, path
endif




; RDIFF construction & image writing
for imap=diff, n_elements(maps.id)-1, 1 do begin

  if not(keyword_set(plot)) then begin
    out_maps[imap].data		= (maps[imap].data  -maps[imap-diff].data)
    out_maps[imap].id_ext	= out_maps[imap].id_ext + id_ext_rdiff
  endif
  
  if keyword_set(dir) then begin
	plotmap, out_maps[imap], dmin=-int_sat, dmax=int_sat, xr=xr, yr=yr, /info, boxcar=boxcar
	write_png, path +'/'+string(imap-diff, format='(I04)')+'.png', tvrd(true=1)
  endif
endfor

return, out_maps
END

;PURPOSE
;wrapper routine for stackplot investigation - click & get

;INPUT
;smap			- map array

;OPTIONAL INPUT
;smap2, smap3		- map arrays (have to contain the same spatial and temporal range as smap) of image processed maps
;			  An assumption is that the processed image is normalized
;min_time, max_time	- time constraints. If either not set, the beginning/end of the 
; 			  map time series will be assumed.
;straight_cut		- if set, the cut_X and cut_Y should be 2-element vectors
;dmin, dmax, log	- graphic keywords (see plot_st_stackplot.pro)
;map_ind		- index of the map to plot

;CALLS
;map_cut_cursor
;st_stackplot
;plot_st_stackplot

;HISTORY
;2015-12-14	JD 	- written
;2015-12-15	JD	- renamed OUTMAP to SMAP2
;			- added keywords SMAP3, MGN
;2016-01-05	JD	- fixed a bug where xrange and yrange were not passed to plotmap
;2016-01-08	JD	- fixed a bug where plot_map_subfield was used instead of plotmap
;2016-10-23	JD	- added keywords WSIZEC (windows size modifier)
;			  and STSIZEC (stackplot window size modifier)
;2016-10-25	JD	- modified: plots, cut_x, cut_y --> plot_cut, stackplot1
;			  also moved the window sequence plotting only after stackplots are calculated
;			  added wsizec modifier for window sequence plotting
;2016-10-25	JD	- added PIC_IND: will write series of many images to disk
;			  to be used together with PIC_DIR
;2016-10-27	JD	- fixed a bug where XRANGE, YRANGE were not used for the initial (clickable) map
;2016-10-31	JD	- added CUT_X, CUT_Y keywords (bypass clicking on the map)
;			- modified the window size for stackplots to be at least 200 pixels
;2016-01-01	JD	- added D2MIN, D2MAX, D3MIN, D3MAX
;			  for 2nd and 3rd stackplot
;			- added keyword WNMOD (+ modificator for window number)
;2016-11-29	JD	- added keyword INTERVAL (same meaning as YTICKINTERVAL but less confusing)
;			- added keywords XTICKINTERVAL and YTICKINTERVAL
;2017-09-26	JD	- removed /transpose from plot_st_stackplot (see there for details)
;			- added plotting of the cut to the original image by default
;2017-10-18	JD	- added keyword RDIFF
;			  if set, changes the first map to be plotted (so that only RD maps are plotted)
;			- moved plotting of the initial map window outside of the "if keyword_set(cut_X)"
;2018-02-22	JD	- added BOXCAR=BOXCAR to plotmap
;			- added /nan to plot_st_stackplot.pro
;2018-03-13	JD	- added color=255 to plot_cut call in IFs
;2018-06-12	JD	- changed straight_cut to an optional keyword in ST_STACKPLOT call
;			- added FAST=FAST keyword
;2018-07-23	JD	- added SLIT_PIX and SLIT_WIDTH
;			- added /nan to st_stackplot calls
;2019-02-12	JD	- renamed WSIZEMOD and STSIZEMOD to WSIZEC and STSIZEC
;			  and implemented that windows cannot be larger than 1000 in any dimension
;2019-02-25	JD	- corrected error when saving windows and smap3 was not set, only smap2 (#206)
;			  changed strmid(map.id, 10, 3) to strmid(map.id, 10, 4)  (for 1600 and 1700 A)
;2019-02-29	JD	- added AIA filter ID to stackplot PNG files (was missing)
;2022-04-21	JD	- changed the min/max window sizes to 1.5d3
;2022-05-04	JD	- moved plot_cut up so that it is visible sooner
;2023-02-21	JD	- added MAX_WIN_SIZE
;			  added smap4
;2023-04-18	JD	- added SPLINE to st_stackplot and to call
;2023-05-04	JD	- corrected image names (were using wrong AIA map.id)
;2024-04-18     JD      - corrected plotting of slit_pix lines
;2026-02-10 JD  - added boxcar to ST_STACKPLOT call (better to smooth individual maps)

PRO STACKPLOTS, smap, smap2=smap2, smap3=smap3, smap4=smap4, mgn=mgn, cut_x=cut_x, cut_y=cut_y, straight_cut=straight_cut,	$
		stackplot1=stackplot1, stackplot2=stackplot2, stackplot3=stackplot3, stackplot4=stackplot4,			$
		fast=fast, xrange=xrange, yrange=yrange,									$
		min_time=min_time, max_time=max_time, map_ind=map_ind, pic_ind=pic_ind, pic_dir=pic_dir,			$
		dmin=dmin, dmax=dmax, d2min=d2min, d2max=d2max, d3min=d3min, d3max=d3max, d4min=d4min, d4max=d4max, log=log,	$
		interval=interval, xtickinterval=xtickinterval, ytickinterval=ytickinterval, 					$
		wsizec=wsizec, stsizec=stsizec, wnmod=wnmod, max_win_size=max_win_size,						$
	 	boxcar=boxcar, rdiff=rdiff, slit_pix=slit_pix, slit_width=slit_width, spline=spline

if NOT(keyword_set(rdiff))   then rdiff	= 0
if NOT(keyword_set(map_ind)) then map_ind = 0 +rdiff

if keyword_set(MGN) then begin
  dmin=0
  dmax=1
endif

if (!d.name NE 'X') then set_plot_x

if not(keyword_set(wsizec)) 	then wsizec  =1.5d ;else wsizec=wsizec
if not(keyword_set(stsizec)) 	then stsizec =1.5d ;else stsizec=stsizec

if keyword_set(cut_X) and ((n_elements(cut_X) NE n_elements(cut_Y)) or (n_elements(cut_X) LT 2)) then begin
  print, ''
  print, '-!- STACKPLOT: malformed input: cut_x, cut_y'
  print, ''
  stop
endif

if keyword_set(interval) and keyword_set(ytickinterval) then begin
	print, '-!- Both INTERVAL and YTICKINTERVAL are set. Using INTERVAL only'
	ytickinterval	= interval
endif
if keyword_set(interval) and not(keyword_set(ytickinterval)) then ytickinterval = interval


NX_MAP		= n_elements(smap[0].data[*,0])
NY_MAP		= n_elements(smap[0].data[0,*])
N_MAP		= n_elements(smap.id)

; xsize_map	= min([600, NX_MAP])
; ysize_map	= min([900, NY_MAP])
xsize_map	= NX_MAP
ysize_map	= NY_MAP


window, 0, xsize=(xsize_map*wsizec < 2d3), ysize=(ysize_map*wsizec < 2d3)
plotmap, smap[map_ind[0]], dmin=dmin, dmax=dmax, log=log, /info, xrange=xrange, yrange=yrange, boxcar=boxcar

  
if not(keyword_set(cut_X)) then begin

  print, 'Click on the map to create the cut for stackplot. Right-click:  Exit'
  print, '                                                  Middle-click: Start over'
  map_cut_cursor, cut_x, cut_y, /plot
endif

if not(keyword_set(wnmod)) then wnmod=0
if not(keyword_set(max_win_size)) then max_win_size = 1d3


;so far, handles only straight cuts
stackplot1	= st_stackplot(smap, cut_x=cut_x, cut_y=cut_y, straight_cut=straight_cut, fast=fast, /nan, $
				min_time=min_time, max_time=max_time, slit_pix=slit_pix, slit_width=slit_width, spline=spline, boxcar=boxcar)

wset, 0
NLINES  = n_elements(stackplot1.xap[0,*])
for il=0, NLINES-1, 1 do begin
  if keyword_set(spline) then plots, stackplot1.xap[*,il], stackplot1.yap[*,il], color=green
  ; if keyword_set(spline) then plots, stackplot1.xp,  stackplot1.yp,  color=red
endfor
plot_cut, stackplot1, thick=2, color=255


if keyword_set(smap2) then begin
  stackplot2	= st_stackplot(smap2, cut_x=cut_x, cut_y=cut_y, straight_cut=straight_cut, fast=fast, /nan, $
				min_time=min_time, max_time=max_time, slit_pix=slit_pix, slit_width=slit_width, spline=spline, boxcar=boxcar)
 if keyword_set(dmin) and not(keyword_set(d2min)) then d2min=dmin
 if keyword_set(dmax) and not(keyword_set(d2max)) then d2max=dmax
endif
if keyword_set(smap3) then begin
  stackplot3	= st_stackplot(smap3, cut_x=cut_x, cut_y=cut_y, straight_cut=straight_cut, fast=fast, /nan, $
				min_time=min_time, max_time=max_time, slit_pix=slit_pix, slit_width=slit_width, spline=spline, boxcar=boxcar)
  if keyword_set(dmin) and not(keyword_set(d3min)) then d3min=dmin
  if keyword_set(dmax) and not(keyword_set(d3max)) then d3max=dmax
endif
if keyword_set(smap4) then begin
  stackplot4	= st_stackplot(smap4, cut_x=cut_x, cut_y=cut_y, straight_cut=straight_cut, fast=fast, /nan, $
				min_time=min_time, max_time=max_time, slit_pix=slit_pix, slit_width=slit_width, spline=spline, boxcar=boxcar)
  if keyword_set(dmin) and not(keyword_set(d4min)) then d4min=dmin
  if keyword_set(dmax) and not(keyword_set(d4max)) then d4max=dmax
endif

NX_ST		= n_elements(stackplot1.stackplot[0,*])		; will use transpose
NY_ST		= n_elements(stackplot1.stackplot[*,0])

if (NY_ST LT 250) then NY_ST	= NY_ST*2
if (NX_ST LT 500) then NX_ST	= NX_ST*2



if (n_elements(map_ind) GT 1) then begin
  for imap=0, n_elements(map_ind)-1, 1 do begin
	window, imap*4, xsize=(xsize_map*wsizec < max_win_size), ysize=(ysize_map*wsizec < max_win_size)
	plotmap, smap[map_ind[imap]], dmin=dmin, dmax=dmax, log=log, /info, xrange=xrange, yrange=yrange, boxcar=boxcar
; 	plots, cut_X, cut_Y, /data
	plot_cut, stackplot1, thick=2, color=255
  endfor
endif

if (n_elements(pic_ind) GT 1) then begin
  if is_string(pic_dir) then begin
    for imap=0, n_elements(pic_ind)-1, 1 do begin
	window, 30, xsize=(xsize_map*wsizec < max_win_size), ysize=(ysize_map*wsizec < max_win_size)
	plotmap, smap[pic_ind[imap]], dmin=dmin, dmax=dmax, log=log, /info, xrange=xrange, yrange=yrange, boxcar=boxcar
; 	plots, cut_X, cut_Y, /data
	plot_cut, stackplot1, thick=2, color=255
	write_png, pic_dir+'ind'+trim(pic_ind[imap])+'.png', tvrd(true=1)
    endfor
    wdelete, 30
  endif else begin
    print, ' -!-   Not a valid string:', pic_dir 
  endelse
endif



xsize_st	= min([1000, NX_ST]) > 200
ysize_st	= min([900, NY_ST])  > 200
window, 2+wnmod, xsize=(xsize_st*stsizec < max_win_size), ysize=(ysize_st*stsizec < max_win_size)
plot_st_stackplot, stackplot1, dmin=dmin, dmax=dmax, log=log, boxcar=boxcar, /nan, xtickinterval=xtickinterval, ytickinterval=ytickinterval, min_time=min_time, max_time=max_time

if keyword_set(smap2) then begin
  window, 6+wnmod, xsize=(xsize_st*stsizec < max_win_size), ysize=(ysize_st*stsizec < max_win_size)
  plot_st_stackplot, stackplot2, dmin=d2min, dmax=d2max, log=log, boxcar=boxcar, /nan, xtickinterval=xtickinterval, ytickinterval=ytickinterval, min_time=min_time, max_time=max_time
endif
if keyword_set(smap3) then begin
  window, 10+wnmod, xsize=(xsize_st*stsizec < max_win_size), ysize=(ysize_st*stsizec < max_win_size)
  plot_st_stackplot, stackplot3, dmin=d3min, dmax=d3max, log=log, boxcar=boxcar, /nan, xtickinterval=xtickinterval, ytickinterval=ytickinterval, min_time=min_time, max_time=max_time
endif
if keyword_set(smap4) then begin
  window, 14+wnmod, xsize=(xsize_st*stsizec < max_win_size), ysize=(ysize_st*stsizec < max_win_size)
  plot_st_stackplot, stackplot4, dmin=d4min, dmax=d4max, log=log, boxcar=boxcar, /nan, xtickinterval=xtickinterval, ytickinterval=ytickinterval, min_time=min_time, max_time=max_time
endif


;save images?
yesno		= ''
path		= ''
file_id		= ''
read, 'Do you want to save the images? [y/n]', yesno
if (yesno EQ 'y') then begin
  path = '/home/jaro/flares/'+strmid(anytim(smap[0].time, /ccsds), 0, 10)+'/pics/stackplots/'
;   read, 'Please enter path:', path
  read, 'Please enter file ID:', file_id
  for imap=0, n_elements(map_ind)-1, 1 do begin
    wset, imap*4
    write_png, path+file_id+'_'+strmid(smap[0].id, 10, 4)+'_map_'+trim(imap)+'.png', tvrd(true=1)
  endfor
  wset, 2
  write_png, path+file_id+'_stackplot_'+strmid(smap[0].id, 10, 4)+'.png', tvrd(true=1)
  if keyword_set(smap2) then begin
    wset, 6+wnmod
    write_png, path+file_id+'_stackplot2_'+strmid(smap2[0].id, 10, 4)+'.png', tvrd(true=1)
  endif
  if keyword_set(smap3) then begin
    wset, 10+wnmod
    write_png, path+file_id+'_stackplot3_'+strmid(smap3[0].id, 10, 4)+'.png', tvrd(true=1)
  endif
  if keyword_set(smap4) then begin
    wset, 14+wnmod
    write_png, path+file_id+'_stackplot4_'+strmid(smap4[0].id, 10, 4)+'.png', tvrd(true=1)
  endif
endif

read, 'Do you want to save the cut? [y/n]', yesno
if (yesno EQ 'y') then begin
  path = '/home/jaro/flares/'+strmid(anytim(smap[0].time, /ccsds), 0, 10)+'/saves/'
;   read, 'Please enter path:', path
  read, 'Please enter file ID:', file_id
  save, filename=path+file_id+'_'+strmid(smap[0].id, 10, 4)+'_cutXY.sav', cut_x, cut_y
endif
















END

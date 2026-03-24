function time_px_shift, time, dt, add=add, subtract=subtract
; shifts the time by dt/2
  tt	= (anytim2utc(time))
  if keyword_set(add)      then tt.time=tt.time+dt*1d3/2d
  if keyword_set(subtract) then tt.time=tt.time-dt*1d3/2d
  out	= anytim(tt, out_style='vms')
return, out
end




;====================================================================================
PRO plot_timeplot, yt_profile, yrange=yrange, trange=trange, min_time=min_time, max_time=max_time, time=time, tind=tind, tmin=tmin, tmax=tmax, ylog=ylog, isotropic=isotropic, charsize=charsize, charthick=charthick, thick=thick, xthick=xthick, ythick=ythick, xmargin=xmargin, ymargin=ymargin, xticks=xticks, yticks=yticks, xminor=xminor, yminor=yminor, xtickname=xtickname, ytickname=ytickname, xtickinterval=xtickinterval, ytickinterval=ytickinterval, xtitle=xtitle, ytitle=ytitle, title=title, inverse=inverse, no_erase=no_erase, erase=erase, transpose=transpose, seconds=seconds, linestyle=linestyle, color=color, psym=psym, boxcar=boxcar, nan=nan, edge_truncate=edge_truncate;, t_offset=t_offset

;INPUT
;--------------------
;yt_profile			- structure containing the evolution of a variable Y 
;				  tags: yplot 	- (1D array)    [units of Y]	time evolution of Y; variable to be plotted
;					dy	- (double)   	[units of Y]	resolution of Y
;					y_units - (string)			units of Y
;					dt	- (double)   	[time, VMS]	temporal resolution
;					tcoord  - (1D array) 	[time, VMS]	temporal coordinates (center of pixels)
;

;PROGRAMMING NOTES
;--------------------
;tcoord				- corresponds always to the center of pixels
;yplot				- always an exact value (no "center of pixel" concept or anything; that one is used for 2D images only)
;transpose			- should be set if the time coordinate is the X one.
;
;
;MODIFICATION HISTORY
;--------------------
;2016-05-06	JD		- adapted from plot_st_stackplot 
;				  to handle evolution plots in a similar manner than stackplots
;				- deprecated use of dmin=dmin, dmax=dmax, /inverse (not valid of 1D variable)
;				- note that /transpose should be used by default for consistency with plot_st_stackplot
;2017-08-28	JD		- added keywords LINESTYLE and COLOR
;2020-03-17	JD		- added keyword PSYM
;2020-04-29	JD		- changed the way YTICKINTERVAL are set
;				- added BOXCAR, NAN, EDGE_TRUNCATE
;				- added TIME, TIND, TMIN, TMAX. Meant as _output_
;
;2021-10-15	JD		- changed xtickinterval to ytickinterval in automatic time setting.
;				NOTE: The whole x/y axes thing needs to be cleaned up (TBD)
;2022-11-03	JD		- corrected: When setting YTICKINTERVAL, changed the default value of 60 (was named 'xtickinterval' not 'ytickinterval')
;
;
;2024-11-05	JD		- decoupled XTHICK/YTHICK from THICK


if keyword_set(boxcar) then begin
  yplot		= smooth(yt_profile.yplot, boxcar, nan=nan, edge_truncate=edge_truncate)
endif else begin
  yplot		= yt_profile.yplot
endelse
tcoord		= yt_profile.tcoord
dy		= yt_profile.dy
dt		= yt_profile.dt
y_units		= yt_profile.y_units
; dt		= 0d


;min_time & max_time OK?
if keyword_set(min_time) then begin
  min_time = anytim(min_time, out_style='vms')
  if (min_time LT min(tcoord)) then begin
	print, ''
	print, '-!-  INCORRECT time range: MIN_TIME, MAX_TIME'
	print, ''
; 	stop
  endif
endif
if keyword_set(max_time) then begin
  max_time = anytim(max_time, out_style='vms')
  if (max_time GT max(tcoord)) then begin
	print, ''
	print, '-!-  INCORRECT time range: MIN_TIME, MAX_TIME'
	print, ''
; 	stop
  endif
endif

if keyword_set(trange) and (keyword_set(min_time) or keyword_set(max_time)) then begin
	print, '-!- Use either trange or min_time/max_time keywords'
	stop
endif
if keyword_set(trange) then begin
	min_time	= min(trange) ;-dt/2d
	max_time	= max(trange) ;+dt/2d
endif


; if not(keyword_set(dy))		then dy		= (deriv(yplot))[0]
if not(keyword_set(yrange)) 	then yrange	= [min(yt_profile.yplot), max(yt_profile.yplot)]
if not(keyword_set(min_time)) 	then min_time	= time_px_shift(min(tcoord), dt, /subtract)
if not(keyword_set(max_time)) 	then max_time	= time_px_shift(max(tcoord), dt, /add)
; if not(keyword_set(trange)) 	then trange	= [ max([min(tcoord), min_time]), min([max(tcoord), max_time]) ]
; if not(keyword_set(trange)) 	then trange	= [ max([min(tcoord)-dt/2d, min_time]), min([max(tcoord)+dt/2d, max_time]) ]

if not(keyword_set(charthick))	then charthick	= 1 +(!D.name EQ 'PS')
if not(keyword_set(thick))	then thick	= 1 +(!D.name EQ 'PS')
if not(keyword_set(charsize))	then charsize	= 1.25
if not(keyword_set(thick))	then thick	= 2
if not(keyword_set(xthick))	then xthick	= thick
if not(keyword_set(ythick))	then ythick	= thick
if not(keyword_set(xmargin))	then xmargin	= [10,3]
if not(keyword_set(ymargin))	then ymargin	= [4,1.5]
if not(keyword_set(xticks))	then xticks	= 0
if not(keyword_set(yticks))	then yticks	= 0
if not(keyword_set(xminor))	then xminor	= 0
if not(keyword_set(yminor))	then yminor	= 0
if not(keyword_set(xtickname))	then xtickname	= replicate('', xticks+1)
if not(keyword_set(ytickname))	then ytickname	= replicate('', yticks+1)
if not(keyword_set(xtitle))	then xtitle	= 'Time profile [' +string(y_units) +']'
if not(keyword_set(ytitle))	then ytitle	= 'Time [UT]'
if not(keyword_set(title))	then title	= ''
;add xtickinterval, ytickinterval here?



;truncate the scoord and tcoord to include only the points within the specified ranges
; sind		= where((scoord -ds/2d GE yrange[0]) and (scoord +ds/2d LE yrange[1]))
tind		= where((time_px_shift(tcoord, dt, /subtract) GE min_time) $
		    and (time_px_shift(tcoord, dt, /add) LE max_time))
; tind		= where((tcoord -dt/2d GE min_time)  and (tcoord +dt/2d LE max_time))
; scoord		= scoord[sind]
tcoord		= tcoord[tind]
; NXI		= n_elements(sind)
NTI		= n_elements(tind)-1
yplot		= yplot[tind[0]:tind[NTI-1]]

ttcoord		= anytim2utc(tcoord)
min_time	= anytim2utc(min_time)
max_time	= anytim2utc(max_time)

;correct for midnights in datasets from various days
;untested as of 2014-11-21
Ndays		= (max_time.mjd - min_time.mjd)
if (Ndays GT 0) then begin
	max_time.mjd	= min_time.mjd
	max_time.time	= max_time.time +(3600L *1000L *24L *long(Ndays))
endif
if (Ndays GT 9) then begin
	print, ''
	print, '-!- Too many days!', Ndays
	print, ''
	stop
endif
if (Ndays GT 0) then begin
  for iday=1L, long(Ndays)-1L, 1L do begin
    inextday			= where(tcoord.mjd EQ tcoord[0].mjd +iday)
    tcoord[inextday].mjd	= tcoord[0].mjd
    tcoord[inextday].time	= tcoord[inextday].time +(3600L *1000L *24L *long(iday))
  endfor
endif

;set tmin and tmax, in seconds
tmin		= min(min_time.time)/1d3
tmax		= max(max_time.time)/1d3
time		= ttcoord.time/1d3


;set up the plot
if NOT(keyword_set(no_erase)) then erase
; if keyword_set(inverse) then begin
;   C = -1d
;   dmax2 = dmin
;   dmin2 = dmax
; endif else begin
;   C = 1d
;   dmax2 = dmax
;   dmin2 = dmin
; endelse


;automatic time tick intervals
if NOT(keyword_set(ytickinterval)) then begin
    ytickinterval=60
    if (tmax-tmin) GE 1200d    then ytickinterval=600 
    if (tmax-tmin) GE 7200d    then ytickinterval=1200
    if (tmax-tmin) GE 3600d *6 then ytickinterval=3600
;   if (tmax-tmin) GE 1200d then ytickinterval=600 else ytickinterval=60
endif
if (yticks EQ 0) and NOT(keyword_set(seconds)) then begin
  ntimeint	= fix((tmax-tmin)/double(ytickinterval))
  ytickname	= strarr(ntimeint+1)
  for it=0, ntimeint, 1 do begin
    ytickname[it] = anytim({mjd:min_time.mjd, time:min_time.time+it*double(ytickinterval)*1d3} , out_style='vms')
    ytickname[it] = strmid(ytickname[it], 12, 5)
  endfor
endif



;plot
if NOT(keyword_set(transpose)) then begin

	plot, 	/nodata, /norm, [yrange[0], yrange[1]], [0d, tmax-tmin], /xs, /ys,	$
		ylog=ylog, charsize=charsize, charthick=charthick, /noerase,		$
		xthick=xthick, ythick=ythick, isotropic=isotropic,			$
		xmargin=[xmargin[0],xmargin[1]], ymargin=[ymargin[0],ymargin[1]], 	$
		xticklen=-0.01, yticklen=-0.01, xticks=xticks, yticks=yticks,		$
		xminor=xminor, yminor=yminor, xtickname=xtickname, ytickname=ytickname, $
		xtickinterval=xtickinterval, ytickinterval=ytickinterval,		$
		xtitle=xtitle, ytitle=ytitle, title=title

	oplot,  yplot, time-tmin, color=color, linestyle=linestyle, thick=thick, psym=psym
	
	plot, 	/nodata, /norm, [yrange[0], yrange[1]], [0d, tmax-tmin], /xs, /ys,	$
		ylog=ylog, charsize=charsize, charthick=charthick, /noerase,		$
		xthick=xthick, ythick=ythick, isotropic=isotropic,			$
		xmargin=[xmargin[0],xmargin[1]], ymargin=[ymargin[0],ymargin[1]], 	$
		xticklen=+0.01, yticklen=+0.01, xticks=xticks, yticks=yticks,		$
		xminor=xminor, yminor=yminor,						$
		xtickinterval=xtickinterval, ytickinterval=ytickinterval,		$
		xtickname=replicate(' ', xticks+20), ytickname=replicate(' ', yticks+20)
endif else begin

	plot, 	/nodata, /norm, [0d, tmax-tmin], [yrange[0], yrange[1]], /xs, /ys,	$
		ylog=ylog, charsize=charsize, charthick=charthick, /noerase,		$
		xthick=xthick, ythick=ythick, isotropic=isotropic,			$
		xmargin=[xmargin[0],xmargin[1]], ymargin=[ymargin[0],ymargin[1]], 	$
		xticklen=-0.01, yticklen=-0.01, xticks=yticks, yticks=xticks,		$
		xminor=yminor, yminor=xminor, xtickname=ytickname, ytickname=xtickname, $
		xtickinterval=ytickinterval, ytickinterval=xtickinterval,		$
		xtitle=ytitle, ytitle=xtitle, title=title

	oplot,  time-tmin, yplot, color=color, linestyle=linestyle, thick=thick, psym=psym


	plot, 	/nodata, /norm, [0d, tmax-tmin], [yrange[0], yrange[1]], /xs, /ys,	$
		ylog=ylog, charsize=charsize, charthick=charthick, /noerase,		$
		xthick=xthick, ythick=ythick, isotropic=isotropic,			$
		xmargin=[xmargin[0],xmargin[1]], ymargin=[ymargin[0],ymargin[1]], 	$
		xticklen=+0.01, yticklen=+0.01, xticks=yticks, yticks=xticks,		$
		xminor=yminor, yminor=xminor,						$
		xtickinterval=ytickinterval, ytickinterval=xtickinterval,		$
		xtickname=replicate(' ', xticks+20), ytickname=replicate(' ', yticks+20)
endelse

end

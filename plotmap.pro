pro plotmap, maps, xrange=xrange, yrange=yrange, pixels=pixels, dmin=dmin, dmax=dmax, charsize=charsize, charthick=charthick, thick=thick, xmargin=xmargin, ymargin=ymargin, isotropic=isotropic, noisotropic=noisotropic, log=log, sqrt=sqrt, xticks=xticks, yticks=yticks, xminor=xminor, yminor=yminor, xtickformat=xtickformat, ytickformat=ytickformat, xtickname=xtickname, ytickname=ytickname, xtickinterval=xtickinterval, ytickinterval=ytickinterval, xticklen=xticklen, yticklen=yticklen, xtitle=xtitle, ytitle=ytitle, title=title, info=info, id=id, notitle=notitle, inverse=inverse, position=position, noerase=noerase, erase=erase, xs=xs, ys=ys, color=color, pos_info=pos_info, no_nan_corr=no_nan_corr, channel=channel, true=true, boxcar=boxcar, nan=nan, edge_truncate=edge_truncate, $
overlay=overlay, levels=levels, frac_levels=frac_levels, c_thick=c_thick, c_annotation=c_annotation, c_charsize=c_charsize, c_charthick=c_charthick, c_colors=c_colors, c_labels=c_labels, c_linestyle=c_linestyle, c_orientation=c_orientation, c_spacing=c_spacing


;Modification history
;(plot_map_subfield.pro)
;2014-May	JD	- keyword "inverse" implemented
;2014-06-06 	JD 	- keyword "position" implemented. Has to be in normalized device units.
;		JD 	- keyword "erase" implemented
;		JD 	- keyword "xs" and "ys" implemented, default values = 1
;2014-07-01	JD	- removed a bug concerning position of individual pixels
;			  with [xmcoord, ymcoord] corresponding to center of individual pixels
;2014-08-01	JD	- added keyword "color"
;2014-08-01	JD	- converted into usage for both PS and X devices
;2014-08-05	JD	- fixed automatic selection of xrange, yrange (if not supplied)
;2014-11-19	JD	- added pos_info: prints lower_left, upper_right
;2014-12-01	JD	- added /noerase: /erase is set by default, kept for compatibility, but not functional
;2014-12-11	JD	- added XTICKFORMAT, YTICKFORMAT
;2015-02-13	JD	- changed automatic setting of dmin = max([min(map.data), 1d0]), dmax=min([max(map.data), 1d5])
;2015-03-03	JD	- added keyword NOISOTROPIC. Keyword ISOTROPIC is now set by default.
;			- added automatic setting of the TITLE keyword to map.id
;2015-03-04	JD 	- reverted to title='' by default
;			- added keywords XTICKNAME, YTICKNAME
;2015-06-17	JD	- added keyword INFO: will put title containing the info on the map
;2015-12-08	JD	- changed the way DMIN is calculated: max([min(map.data), keyword_set(log)])
;
;(plotmap.pro)
;2015-12-15	JD	- renamed to plotmap.pro
;2015-12-16	JD	- fixed a bug where a large array of maps froze the console instead of just plotting map[0]
;2016-01-08	JD	- fixed the NaN values resulting in black map (hopefully)
;			  added a /NO_NAN_CORR for preventing this
;2016-01-14	JD	- NaN values are now changed to INVERSE keyword (0 or 1) instead of 0
;2016-01-28	JD	- added explicit inverse=0 if keyword not set
;2016-02-09	JD	- changed the way DMIN, DMAX are set for HMI maps
;2016-04-27	JD	- added a check for the ind if bad xr, yr are set
;2016-11-16	JD	- keyword CHANNEL works only for the X device; for PS one has to use true=true
;2017-01-16	JD	- changed keyword INFO: Now prints also the .odur tag (.dur tag if .odur does not exist)
;2017-04-26	JD	- added keyword BOXCAR
;2018-01-25	JD	- changed the way information is plotted in TITLE (if /INFO set)
;			- added averaging if the input map is an array
;			  So far only works if TRUE is not set
;			- added /NAN: Unlike st_stackplot or plot_st_stackplot, this should not be needed here;
;			  since we already have a NaN or Inf protection implemented
;			- added /EDGE_TRUNCATE to SMOOTH call
;2018-03-14	JD	- added X/YTICKINTERVAL
;2019-01-29	JD	- added OVERLAY (and corresponding LEVELS and C_ keywords from CONTOUR procedure)
;			  Note that this assumes the user knows what (s)he is doing
;			  Note that the current implementation of contour does not take into account relative ROLL_ANGLES
;			  the SSW plot_map is perhaps more intelligent in this regard
;			- changed DMIN, DMAX to double
;2019-10-15	JD	- added keyword SQRT
;2020-05-14	JD	- added PIXELS: to label axes in pixels instead of arc seconds
;2020-05-25	JD	- set c_charsize to !p.charsize, if not set directly
;2020-05-30	JD	- added keyword ID
;2021-03-24	JD	- changed the map averaging in time, using middle of map array
;2022-04-21	JD	- changed default charsize to !p.charsize
;2023-04-26	JD	- added XTICKLEN, YTICKLEN
;2023-05-11	JD	- changed dmin setting for 335A, 94A, or other weaker imaging datasets (1 -> 0.1 if /log set)
;2024-08-29	JD	- changed '[arc sec]' to '[arcsec]' per usual abbreviation
;2025-01-21	JD	- added FRAC_LEVELS (fractional levels for STIX)
;2025-04-22	JD	- changed averaging, now works for any input map range
;2025-06-16	JD	- changed INFO if input map is a range / averaged

; NOTES
; /pixels		- this will plot the image in pixels instead of arc sec units
;			  Note that in this case, the axes are shrunk to pixels,
;			  no whitespaces are given to correspond to exact XRANGE, YRANGE


; if (n_elements(maps.id) GT 1) then map = maps[0] else map = maps
; ;this does not do anything, but it is explicit.

; if (n_elements(maps.id) GT 1) and not(keyword_set(true)) then map = maps[0] else begin map = maps
;this does not do anything, but it is explicit.

; if (n_elements(maps.id) GT 1) and not(keyword_set(true)) and keyword_set(average) then begin
;   map		= maps[0]
;   map.data	= total(maps[0:n_elements(maps.id)-1].data, 3)/n_elements(maps.id)
;   ;watch out for the format of the data tag! Integer or Float, it might create different results.
; endif


if not(keyword_set(true)) then begin 
  if (n_elements(maps.id) EQ 1) then begin
    map 	= maps[0]
  endif else begin
;     map		= maps[0]
    map 	= maps[fix(n_elements(maps.id)/2)]
    if (n_elements(maps.id) LE 100) then begin
      map.data	= total(maps[0:n_elements(maps.id)-1].data, 3)/n_elements(maps.id)
      print, '% PLOTMAP: Averaging the input ' +trim(n_elements(maps.id)) +' maps for display'
    endif else begin
      ; print, '-!- PLOTMAP:  Too many maps to average. plotting first map only'
      map.data	= total(maps[0:n_elements(maps.id)-1].data, 3)/n_elements(maps.id)
      print, '-!- PLOTMAP:  Too many maps to average?'
    endelse
  endelse
endif else begin
  map 		= maps
endelse


;treat the NaN or Infty values
if NOT(keyword_set(inverse)) then inverse=0
indf	 	= where(FINITE(map.data) EQ 0)
if NOT(keyword_set(no_nan_corr)) then begin
  if (float(!version.release) GE 8.) then begin
    if (indf[0] NE -1) or (indf[0] NE !null) then map.data[indf]	= inverse
  endif else begin
    if (indf[0] NE -1) then map.data[indf]	= inverse
  endelse
endif 

if (!d.name EQ 'PS') and keyword_set(channel) then begin
  print, ''
  print, '-!-  PLOTMAP: keyword CHANNEL not allowed for PS device'
  print, ''
  stop
endif

;untested as of 2016-11-16
if (!d.name EQ 'PS') and keyword_set(true) and ((size(map.data))[0] NE 3) then begin
  print, ''
  print, '-!-  PLOTMAP: keyword TRUE requires the .DATA tag to be a 3-dimensional array'
  print, ''
  stop
endif

if tag_exist(map[0], 'odur') then odur = map[0].odur else odur = map[0].dur



get_map_coord, map[0], xmcoord, ymcoord

if not(keyword_set(color))	then color	= 0
if not(keyword_set(charsize))	then charsize	= !p.charsize
if not(keyword_set(charthick))	then charthick	= 1 +(!D.name EQ 'PS')
if not(keyword_set(thick))	then thick	= 1 +(!D.name EQ 'PS')
if not(keyword_set(xrange))	then xrange	= [min(xmcoord)-map.dx/2d, max(xmcoord)+map.dx/2d]
if not(keyword_set(yrange))	then yrange	= [min(ymcoord)-map.dy/2d, max(ymcoord)+map.dy/2d]
; if not(keyword_set(xrange))	then xrange	= [min(xmcoord),max(xmcoord)]
; if not(keyword_set(yrange))	then yrange	= [min(ymcoord),max(ymcoord)]
if not(keyword_set(xs))		then xs		= 1
if not(keyword_set(ys))		then ys		= 1
if not(keyword_set(xmargin))	then xmargin	= [10,3]
if not(keyword_set(ymargin))	then ymargin	= [6,1.5]
if not(keyword_set(xticks))	then xticks	= 0
if not(keyword_set(yticks))	then yticks	= 0
if not(keyword_set(xminor))	then xminor	= 0
if not(keyword_set(yminor))	then yminor	= 0
if not(keyword_set(xticklen))	then xticklen	= 0.01
if not(keyword_set(yticklen))	then yticklen	= 0.01
; if not(keyword_set(title))	then title	= map.id +'  '+map.time
; if keyword_set(notitle)		then title	= ''
if not(keyword_set(title))	then title	= ''

if not(keyword_set(title)) and not(keyword_set(notitle)) and keyword_set(info) then begin
;   title=map.id + '  ' +map.time + '   Original exptime: ' +string(odur, format='(F7.3)')
  title	=map.id 
  if tag_exist(map[0], 'id_ext') then begin
    title=title+'  '+map[0].id_ext
  endif
  if (n_elements(maps.id) EQ 1) then begin
    title	=title+ '  ' +maps[0].time 
  endif else begin
    title	=title+ '  ' +maps[0].time +' -- ' +maps[n_elements(maps.id)-1].time
  endelse
  if tag_exist(map[0], 'odur') then begin
    title=title+ '   ODUR: ' +string(odur, format='(F7.3)')+' s'
  endif else begin
    title=title+ '   DUR: ' +string(map[0].dur, format='(F7.3)')+' s'
  endelse
endif
if not(keyword_set(title)) and not(keyword_set(notitle)) and not(keyword_set(info)) and keyword_set(id) then begin
;   title=map.id + '  ' +map.time + '   Original exptime: ' +string(odur, format='(F7.3)')
  title	=map.id 
endif


if (map[0].id EQ 'SDO HMI_FRONT2 6173') then begin
  if not(keyword_set(dmin)) 	then dmin	= -1d3
  if not(keyword_set(dmax))	then dmax	= +1d3
endif else begin
  ; not HMI?
  ; is this a 335A filter or any other weaker filter?
  if (map[0].id EQ 'SDO AIA_1 335') or (map[0].id EQ 'SDO AIA_4 94') or (max(map[0].data) LT 500.) then begin
    log_modif	= keyword_set(log) *0.1
  endif else begin
    log_modif = keyword_set(log)
  endelse
  if not(keyword_set(dmin))	then dmin	= double(max([min(map.data), log_modif]))
  if not(keyword_set(dmax))	then dmax	= double(min([max(map.data), 1d5]))
endelse

; 2017-04-26
if keyword_set(boxcar) then begin 
  if keyword_set(true) then begin
	for ist=0, 2 do begin
	  map[0].data[*,*,ist]	= smooth(reform(map[0].data[*,*,ist]), boxcar, nan=nan, edge_truncate=edge_truncate)
	endfor
  endif else begin
	map[0].data	= smooth(map[0].data, boxcar, nan=nan, edge_truncate=edge_truncate)
  endelse
endif



if not(keyword_set(isotropic)) and NOT(keyword_set(noisotropic)) then isotropic=1

if keyword_set(inverse) then begin
  C = -1d
  dmax2 = dmin
  dmin2 = dmax
endif else begin
  C = 1d
  dmax2 = dmax
  dmin2 = dmin
endelse


; some checks for contour plotting (incomplete!)
if keyword_set(OVERLAY) then begin

  if keyword_set(frac_levels) and keyword_set(levels) then begin
    print, '% PLOTMAP:  Overlay LEVELS set along with FRAC_LEVELS, using FRAC_LEVELS'
  endif
  if keyword_set(frac_levels) then levels = dmax *frac_levels

    
  if NOT(keyword_set(levels)) then begin
    if keyword_set(log) then levels = 10^(0.5d*dindgen((alog10(long(dmax*10d)/10d)-alog10(long(dmin*10d)/10d) )*2d +1d))	$
			else levels = dmax *[0.1d, 0.25d, 0.5d, 0.75d]

    print, '% PLOTMAP:  Overlay/LEVELS not set, setting manually to ' +string(transpose(levels))
  endif ; else levels 	= sort(levels)

  if keyword_set(c_thick) then begin
    if n_elements(c_thick) LT n_elements(levels) then begin
      c_thick = replicate(c_thick[0], n_elements(levels))
      print, '% PLOTMAP:  Too few C_THICK set, setting all to ' +trim(c_thick[0])
    endif
  endif

  if (keyword_set(c_labels)) and not(keyword_set(c_charsize)) then begin
    c_charsize = !p.charsize
    print, '% PLOTMAP:  C_CHARSIZE set to default value'
  endif
endif





; if NOT(keyword_set(noerase)) then erase
if NOT(keyword_set(noerase)) and NOT(keyword_set(overlay)) then erase


ind 	= where((xmcoord -map[0].dx/2d GE xrange[0]) and (xmcoord +map[0].dx/2d LE xrange[1]) and $
		(ymcoord -map[0].dy/2d GE yrange[0]) and (ymcoord +map[0].dy/2d LE yrange[1]))
		
if (float(!version.release) LT 8.) then begin
  if (ind[0] EQ -1) then begin 
    print, ''
    print, ' -!- PLOTMAP: Bad XR, YR input; no pixels to plot ' 
    print, ''
    stop
  endif
endif else begin
  if (ind[0] EQ !null) then begin 
    print, ''
    print, '-!- PLOTMAP: Bad XR, YR input; no pixels to plot'
    print, ''
    stop
  endif
endelse


; ind 	= where((xmcoord GE xrange[0]) and (xmcoord LE xrange[1]) and (ymcoord GE yrange[0]) and (ymcoord LE yrange[1]))
; 
; lower_left	= convert_coord(min(xmcoord[ind]), min(ymcoord[ind]), /data, /to_device)
; upper_right	= convert_coord(max(xmcoord[ind]), max(ymcoord[ind]), /data, /to_device)


xp0		= where(xmcoord[*,0] EQ min(xmcoord[ind]))	& xp1	= where(xmcoord[*,0] EQ max(xmcoord[ind]))
yp0		= where(ymcoord[0,*] EQ min(ymcoord[ind]))	& yp1	= where(ymcoord[0,*] EQ max(ymcoord[ind]))



if keyword_set(pixels) then begin
  xrangep	= [xp0, xp1]
  yrangep	= [yp0, yp1]
  if not(keyword_set(xtitle))	then xtitle	= 'Image X [pixel]'
  if not(keyword_set(ytitle))	then ytitle	= 'Image Y [pixel]'
endif else begin
  xrangep	= xrange
  yrangep	= yrange
  if not(keyword_set(xtitle))	then xtitle	= 'Solar X [arcsec]'
  if not(keyword_set(ytitle))	then ytitle	= 'Solar Y [arcsec]'
endelse


plot, 	/nodata, /norm, [xrangep[0], xrangep[1]], [yrangep[0], yrangep[1]], xs=ys, ys=ys,		$
	charsize=charsize, charthick=charthick, thick=thick, 						$
	xthick=thick, ythick=thick, xmargin=[xmargin[0],xmargin[1]], ymargin=[ymargin[0],ymargin[1]], isotropic=isotropic, /noerase, $
	xticklen=-xticklen, yticklen=-yticklen, xticks=xticks, yticks=yticks, xminor=xminor, yminor=yminor, 	$
	xtickformat=xtickformat, ytickformat=ytickformat, xtickname=xtickname, ytickname=ytickname,	$
	xtickinterval=xtickinterval, ytickinterval=ytickinterval,					$
	xtitle=xtitle, ytitle=ytitle, title=title, position=position, color=color

	
if keyword_set(pixels) then begin
  lower_left	= convert_coord( xp0, yp0, /data, /to_device)
  upper_right	= convert_coord( xp1, yp1, /data, /to_device)
endif else begin
  lower_left	= convert_coord( min(xmcoord[ind])-map[0].dx/2d, min(ymcoord[ind])-map[0].dy/2d,  /data, /to_device)
  upper_right	= convert_coord( max(xmcoord[ind])+map[0].dx/2d, max(ymcoord[ind])+map[0].dy/2d,  /data, /to_device)
endelse


if NOT(keyword_set(overlay)) then begin

  ;PS and X devices have different standard regarding sizes. Careful...
  if (!D.name EQ 'PS') then begin
    if (keyword_set(log)) and not(keyword_set(sqrt)) then begin
	tv, bytscl(C*(alog10(map.data[xp0:xp1,yp0:yp1,*] > (dmin) < (dmax))), 				$
		   min=(C*alog10(dmin2)), max=(C*alog10(dmax2)), /nan),					$
	    lower_left(0,0), lower_left(1,0), /device, true=true,					$
	    xsize=upper_right(0,0)-lower_left(0,0)+1, ysize=upper_right(1,0)-lower_left(1,0)+1
    endif 
    if (keyword_set(sqrt)) and not(keyword_set(log)) then begin
	tv, bytscl(C*(sqrt(map.data[xp0:xp1,yp0:yp1,*] > (dmin) < (dmax))),				$
		   min=(C*sqrt(dmin2)), max=(C*sqrt(dmax2)), /nan),					$
	    lower_left(0,0), lower_left(1,0), /device, true=true,					$
	    xsize=upper_right(0,0)-lower_left(0,0)+1, ysize=upper_right(1,0)-lower_left(1,0)+1
    endif
    if not(keyword_set(log)) and not(keyword_set(sqrt)) then begin
	tv, bytscl(C*(map.data[xp0:xp1,yp0:yp1,*] > (dmin) < (dmax)), min=(C*dmin2), max=(C*dmax2), /nan), $
	    lower_left(0,0), lower_left(1,0), /device, true=true, $
	    xsize=upper_right(0,0)-lower_left(0,0)+1, ysize=upper_right(1,0)-lower_left(1,0)+1
    endif
  endif
  if (!D.name EQ 'X') then begin
    if (keyword_set(log)) and not(keyword_set(sqrt)) then begin
	tv, bytscl(congrid(C*(alog10(map.data[xp0:xp1,yp0:yp1] > (dmin) < (dmax))),			$
			   upper_right(0,0)-lower_left(0,0)+1, upper_right(1,0)-lower_left(1,0)+1),	$
		   min=(C*alog10(dmin2)), max=(C*alog10(dmax2)), /nan),					$
	    lower_left(0,0), lower_left(1,0), /device, channel=channel,					$
	    xsize=upper_right(0,0)-lower_left(0,0)+1, ysize=upper_right(1,0)-lower_left(1,0)+1
    endif
    if (keyword_set(sqrt)) and not(keyword_set(log)) then begin
	tv, bytscl(congrid(C*(sqrt(map.data[xp0:xp1,yp0:yp1] > (dmin) < (dmax))),			$
			   upper_right(0,0)-lower_left(0,0)+1, upper_right(1,0)-lower_left(1,0)+1),	$
		   min=(C*sqrt(dmin2)), max=(C*sqrt(dmax2)), /nan),					$
	    lower_left(0,0), lower_left(1,0), /device, channel=channel,					$
	    xsize=upper_right(0,0)-lower_left(0,0)+1, ysize=upper_right(1,0)-lower_left(1,0)+1
    endif
    if not(keyword_set(log)) and not(keyword_set(sqrt)) then begin
	tv, bytscl(congrid(C*(map.data[xp0:xp1,yp0:yp1] > (dmin) < (dmax)),				$
			   upper_right(0,0)-lower_left(0,0)+1, upper_right(1,0)-lower_left(1,0)+1),	$
		   min=(C*dmin2), max=(C*dmax2), /nan),							$
	    lower_left(0,0), lower_left(1,0), /device, channel=channel,					$
	    xsize=upper_right(0,0)-lower_left(0,0)+1, ysize=upper_right(1,0)-lower_left(1,0)+1
    endif
  endif
endif else begin	; overlay set


  contour, map.data[xp0:xp1,yp0:yp1], xmcoord[xp0:xp1,0], ymcoord[0,yp0:yp1], /data,			$
	   xstyle=xs+4, ystyle=ys+4, over=(overlay gt 0), noerase=(overlay eq 0), 			$
; 	   xrange=dxrange,yrange=dyrange,								$
	   max_value=dmax, min_value=dmin,								$
	   levels=levels, c_thick=c_thick, c_annotation=c_annotation, c_colors=c_colors,		$
	   c_labels=c_labels, c_linestyle=c_linestyle, c_orientation=c_orientation, c_spacing=c_spacing,$
	   c_charsize=c_charsize, c_charthick=c_charthick
endelse


plot, 	/nodata, /norm, [xrangep[0], xrangep[1]], [yrangep[0], yrangep[1]], xs=xs, ys=ys, 		$
	charsize=charsize, charthick=charthick, thick=thick,						$ 
	xthick=thick, ythick=thick, xmargin=[xmargin[0],xmargin[1]], ymargin=[ymargin[0],ymargin[1]], isotropic=isotropic, /noerase, $ 
	xticklen=+xticklen, yticklen=+yticklen, xticks=xticks, yticks=yticks, xminor=xminor, yminor=yminor, 	$
	xtickformat=xtickformat, ytickformat=ytickformat,						$
	xtickinterval=xtickinterval, ytickinterval=ytickinterval,					$
	xtickname=replicate(' ', xticks+20), ytickname=replicate(' ', yticks+20), position=position, color=color

if keyword_set(pos_info) then print, lower_left, upper_right

end

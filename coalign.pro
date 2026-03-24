; PURPOSE
; Manual coalignment of two maps
;
;
; INPUT
; map1			- map array used as a base
; map2			- map array to be coaligned
; rot_angle		- angle to rotate the map2
; xa, xb, ya, yb	- shifts to map2
; 
; OPTIONAL INPUT
; xrange, yrange	- (keywords) FOV to plot
; dmin, dmax		- (keywords) scaling of the base map
; log			- (keyword)  log scaling of the base map
; levels		- (keyword)  levels of map2.data to contour
; c_color		- (keyword)  colors to the levels
; level_check		- (keyword)  plots an additional window with map_coal
; 				     and contours chosen over it
;
; OPTIONAL OUTPUT
; mapc			- coaligned map array
;
;
; NOTES
; 
; 1. 	If (xa NE xb) or (ya NE yb), then a stretch to the map2 coordinates has to be applied.
;	This is not implemented yet
;
;
;
; HISTORY
; 2019-10-07		JD	- adapted from a script for manual coalignment
; 2019-11-08		JD	- changed XR, YR to XRANGE, YRANGE
; 2020-05-23		JD	- added RCENTER
; 2025-06-17		JD	- disabled map averaging here, leave it to plotmap
;				- now using get_screen_size() to set window size automatically


PRO COALIGN, 	map1, log=log, dmax=dmax, dmin=dmin, xrange=xrange, yrange=yrange,				$
		map2, rot_angle=rot_angle, rcenter=rcenter, xa=xa, xb=xb, ya=ya, yb=yb,				$
		levels=levels, c_colors=c_colors, mapc=mapc, level_check=level_check				


if not(keyword_set(xa)) or not(keyword_set(xb)) then begin
  print, '% COALIGN:  XA or XB not set, assuming zeroes'
  xa		= 0d
  xb		= 0d
endif
if not(keyword_set(ya)) or not(keyword_set(yb)) then begin
  print, '% COALIGN:  YA or YB not set, assuming zeroes'
  ya		= 0d
  yb		= 0d
endif
if not(keyword_set(rot_angle)) then begin
  print, '% COALIGN:  ROT_ANGLE not set, assuming zero'
  rot_angle	= 0d
endif



if not(keyword_set(levels)) and keyword_set(c_colors) then begin
  print, '-!-  COALIGN:  LEVELS for C_COLORS not set'
  stop
endif

; deal with maps
if (n_elements(map1.id) EQ 1) then begin
  map_base 	= map1[0]
endif else begin
  map_base	= map1
  ; map_base 	= map1[0]
  ; if (n_elements(maps.id) LE 100) then begin
    ; map_base.data	= total(map_base[0:n_elements(map_base.id)-1].data, 3)/n_elements(map_base.id)
    print, '% COALIGN:  Base map1 is an array. Averaging data tag over ' +trim(n_elements(map_base.id)) +' maps for display'
  ; endif else begin
    ; print, '-!- COALIGN:  Base map1 is an array. Too many maps to average, plotting first map only'
  ; endelse
endelse



if (n_elements(map2.id) EQ 1) then begin
  map_coal 	= map2[0]

endif else begin
  map_coal	= map2
  ; map_coal 	= map2[0]
  ; if (n_elements(maps.id) LE 100) then begin
    ; map_coal.data	= total(map_coal[0:n_elements(map_coal.id)-1].data, 3)/n_elements(map_coal.id)
    print, '% COALIGN:  Map2 array to coalign. Averaging data tag over ' +trim(n_elements(map_coal.id)) +' maps for display'
  ; endif else begin
    ; print, '-!- COALIGN:  Map2 array to coalign. Too many maps to average, plotting first map only'
  ; endelse
endelse
map_coal	= rot_map(map_coal[0], rot_angle, rcenter=rcenter)




dim		= get_screen_size()
if (min(dim) GE 2000) then devsize=2000 else devsize=1000


; Plot the base map
wdef, 28, devsize
plotmap,	map_base, log=log, /info, xrange=xrange, yrange=yrange, dmin=dmin, dmax=dmax



; Coalign the over_map
get_map_coord, map_coal, xmap_coal, ymap_coal

if keyword_set(level_check) then begin
  wdef, 30, devsize
  plotmap,	map_coal, log=log, /info, xrange=xrange, yrange=yrange
  plotmap, 	map_coal, log=log, /info, xrange=xrange, yrange=yrange, /over, levels=levels, c_colors=c_colors
endif

; adjust the map_coal
x0		= min(xmap_coal) -map_coal[0].dx/2d		& x1	= max(xmap_coal) +map_coal[0].dx/2d
y0		= min(ymap_coal) -map_coal[0].dy/2d		& y1	= max(ymap_coal) +map_coal[0].dy/2d
x0 		= x0 +xa					& x1	= x1 +xb
y0 		= y0 +ya					& y1	= y1 +yb
NX		= n_elements(map_coal[0].data[*,0])
NY		= n_elements(map_coal[0].data[0,*])

map_coal.xc	= (x0 +x1)/2d
map_coal.yc	= (y0 +y1)/2d
map_coal.dx	= (x1 -x0)/double(NX)
map_coal.dy	= (y1 -y0)/double(NX)
; NOTE: 
; The IDL Mapping Software  http://www.lmsal.com/solarsoft/sswdoc/local_copy/maps/maps.html#s1.1
; specifies that the XC and YC are coordinates of the _center of the image_


; plot the contours over the base map
wset, 28
plotmap,	map_coal, log=log, xrange=xrange, yrange=yrange, levels=levels, c_colors=c_colors, /over


mapc 		= map_coal
END

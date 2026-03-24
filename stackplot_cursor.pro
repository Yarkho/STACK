pro STACKPLOT_CURSOR, line_x=line_x, line_y=line_y, vel=vel, d_vel=d_vel, plot=plot, transpose=transpose, quiet=quiet, soho=soho, color=color, linestyle=linestyle, ds=ds, dt=dt

;PURPOSE
;  To measure velocities from plot_st_stackplot
;  by point & click using mouse cursor
;
;INPUT
;  None
;
;OPTIONAL INPUT
;Transpose			- (keyword) has to be set if the plot_st_stackplot used it.
;				  Othwerise returns 1/v instead of v
;SOHO				- (keyword) set if the stackplots are generated from SOHO data
;				  or other instrument at L1; since then the arc second is slightly shorter
;Quiet				- (keyword) set if you don't want any console output
;
;OUTPUT
;  None
;
;OPTIONAL OUTPUT
;  Line_x, line_y		- Line coordinates (for plot_st_stackplot_line, TBD)
;  Vel				- calculated velocities
;  D_vel			- velocity uncertainty (crude estimate)
;  DS, DT			- uncertainties in the spatial and temporal resolution (default 0.75 arcsec and 6 s)
;
;PROGRAMMING NOTES
;  Note that the program expects to be used after PLOT_ST_STACKPLOT.
;  
;
;HISTORY
;2015-12-17	JD		- adapted from map_line_cursor.pro
;2016-01-11	JD		- added calculation of the velocity uncertainty based on a 'rod estimate'
;				  with rod width being given by AIA resolution (1.5")
;				  (longest path in shortest time vs shortest path in logest time in a 'rod' on stackplot)
;2016-01-12	JD		- formatted the output for line_x and line_y to be copy-paste ready
;				- added DS, DT as keywords
;2016-01-20	JD		- changed calculation of D_vel and D_vel0 using the sqrt sigma formula



if 	keyword_set(soho)	then arcsec2km = 718d else arcsec2km = 725d
if not(keyword_set(color))	then color=0
if not(keyword_set(linestyle))	then linestyle=2

jumpBegin:
delvarx, line_x, line_y

!mouse.button = 0
i=0	& x=dblarr(100) 	& y=dblarr(100)

while (!mouse.button NE 4) do begin
;   print, !mouse.button
  if (!mouse.button EQ 2) then begin
    goto, jumpBegin 
  endif else begin
    cursor, xc, yc, /data
    x[i]=xc & y[i] = yc
    plots, x[i], y[i], psym=1, /data
    if (i GE 1) then plots, x[i-1:i], y[i-1:i], /data, color=color, linestyle=linestyle
    i=i+1 & wait, 0.2
  endelse
endwhile
line_X=x[0:i-2]
line_Y=y[0:i-2]

; if keyword_set(vertical) then line_X[1:-1] = line_X[0]

if     keyword_set(plot)	then plots, line_X, line_Y, /data
if not(keyword_set(quiet))	then begin
  out_line_x	= 'line_x = ['
  out_line_y	= 'line_y = ['
  for j=0, i-3, 1 do begin
    out_line_x	= out_line_x +string(line_x[j], format='(F9.2)')+', '
    out_line_y	= out_line_y +string(line_y[j], format='(F9.2)')+', '
  endfor
  out_line_x	= out_line_x +string(line_x[i-2], format='(F9.2)')+']'
  out_line_y	= out_line_y +string(line_y[i-2], format='(F9.2)')+']'
  print, out_line_x
  print, out_line_y
  print, ''
endif


vel		= dblarr(i-2)			; velocity
D_vel		= dblarr(i-2)			; first-order uncertainty
D_vel0		= dblarr(i-2)			; first-order uncertainty based on ds=0.75


if not(keyword_set(ds)) then ds = 0.75d
if not(keyword_set(dt)) then dt = 6d

;calculate velocities
;Note: x=scoord, y=tcoord. If /transpose is set, we have to do ^(-1)
for j=0, i-3, 1 do begin

  vel[j]	= (line_x[j+1] -line_x[j]) / (line_y[j+1] -line_y[j]) / arcsec2km				; km s^(-1)
  if     keyword_set(transpose) then vel[j] = 1d/vel[j]

  ;uncertainty. Take the position uncertainty to be half the AIA resolution, i.e., 0.75"
  ;             Take the time uncertainty to be half the cadence, i.e., 6 s
  if not(keyword_set(transpose)) then begin
;     D_vel[j]	= 1/2d /arcsec2km  *( (line_x[j+1] -line_x[j] +2*ds)/ (line_y[j+1] -line_y[j] -2*dt) $
; 				     -(line_x[j+1] -line_x[j] -2*ds)/ (line_y[j+1] -line_y[j] +2*dt) )
;     D_vel0[j]	= 1/2d /arcsec2km  *( (line_x[j+1] -line_x[j] +1.5)/ (line_y[j+1] -line_y[j] -2*dt) $
; 				     -(line_x[j+1] -line_x[j] -1.5)/ (line_y[j+1] -line_y[j] +2*dt) )
    D_vel[j]	= sqrt(  arcsec2km^2d *2d* ds^2d *(1d/(line_y[j+1]-line_y[j]))^2d 			$
			+2d*dt^2d *((line_x[j+1]-line_x[j])*arcsec2km/(line_y[j+1]-line_y[j])^2d)^2d )
    D_vel0[j]	= sqrt(  arcsec2km^2d *2d* (0.75d)^2d *(1d/(line_y[j+1]-line_y[j]))^2d 			$
			+2d*6d^2d *((line_x[j+1]-line_x[j])*arcsec2km/(line_y[j+1]-line_y[j])^2d)^2d )
 endif else begin
;     D_vel[j]	= 1/2d *arcsec2km  *( (line_y[j+1] -line_y[j] +2*ds)/ (line_x[j+1] -line_x[j] -2*dt) $
; 				     -(line_y[j+1] -line_y[j] -2*ds)/ (line_x[j+1] -line_x[j] +2*dt) )
;     D_vel0[j]	= 1/2d *arcsec2km  *( (line_y[j+1] -line_y[j] +1.5)/ (line_x[j+1] -line_x[j] -2*dt) $
; 				     -(line_y[j+1] -line_y[j] -1.5)/ (line_x[j+1] -line_x[j] +2*dt) )
    D_vel[j]	= sqrt(  arcsec2km^2d *2d* ds^2d *(1d/(line_x[j+1]-line_x[j]))^2d 			$
			+2d*dt^2d *((line_y[j+1]-line_y[j])*arcsec2km/(line_x[j+1]-line_x[j])^2d)^2d )
    D_vel0[j]	= sqrt(  arcsec2km^2d *2d* (0.75d)^2d *(1d/(line_x[j+1]-line_x[j]))^2d 			$
			+2d*6d^2d *((line_y[j+1]-line_y[j])*arcsec2km/(line_x[j+1]-line_x[j])^2d)^2d )
  endelse

  if not(keyword_set(quiet)) 	then print, 'Velocity for segment ', trim(j+1), ' is ',		$
					     string(vel[j], format='(F9.2)'), ' km/s   +- ',	$
					     string(D_vel[j], format='(F9.2)'), ' km/s    (', 	$
					     string(D_vel0[j], format='(F9.2)'), ' km/s)'
endfor

end

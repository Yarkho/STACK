pro MAP_CUT_CURSOR, cut_x, cut_y, plot=plot, vertical=vertical, $
			linestyle=linestyle, thick=thick, color=color

;PURPOSE
;  To define 'curved' cut for stackplot construction
;  Expected is an image window with defined data coordinates.
;
;INPUT
;  None
;
;OUTPUT
;  Cut coordinates: Cut_X, Cut_Y
;
;
;HISTORY
;2014-12-10	JD		- adapted from console script
;2015-12-14	JD		- added mouse.button = 2 : to start over
;2015-12-16	JD		- renamed to map_cut_cursor.pro
;2019-04-11	JD		- added LINESTYLE, THICK, COLOR
; 2024-04-18    JD              - formatted output CUT_X, CUT_Y

jumpBegin:
; delvar, cut_x, cut_y

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
    i=i+1 & wait, 0.2
  endelse
endwhile
Cut_X=x[0:i-2]
Cut_Y=y[0:i-2]

if keyword_set(vertical) then Cut_X[1:-1] = Cut_X[0]

if keyword_set(plot) then plots, Cut_X, Cut_Y, /data, linestyle=linestyle, thick=thick, color=color
; print, cut_X, cut_Y


; 2024-04-18
NC		= n_elements(cut_x)
cx_string	= ''
cy_string	= ''

for ic=0, NC-1 do begin
  if (ic NE NC-1) then begin
    cx_string	= cx_string +trim(string(cut_x[ic], format='(F10.2)'))+', '
    cy_string	= cy_string +trim(string(cut_y[ic], format='(F10.2)'))+', '
  endif else begin
    cx_string	= cx_string +trim(string(cut_x[ic], format='(F10.2)'))
    cy_string	= cy_string +trim(string(cut_y[ic], format='(F10.2)'))
  endelse
endfor
print, 'cut_x = ['+cx_string+']'
print, 'cut_y = ['+cy_string+']'



END

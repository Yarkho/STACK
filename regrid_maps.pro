FUNCTION REGRID_MAPS, maps_in, xc=xc, yc=yc, dx=dx, dy=dy, NX=NX, NY=NY, zeroXC=zeroXC, zeroYC=zeroYC


; REGRID_MAPS
; 
; PURPOSE
; to regrid maps to a common grid
;
; INPUT
; maps_in			- map array
; 
; OPTIONAL INPUT
; XC, YC			- center coordinate. If not, averages of maps_in.xc and maps_in.yc are used
; DX, DY			- 
; NX, NY			- number of pixels for new map array
;
; OUTPUT	
; out_maps			- regridded (interpolated) maps
;
; NOTES & SIDE EFFECTS
; 1. Assumes that solar North is up, and no rotation is present
;    Otherwise you'll need to use something else
;
; 2. Regridding via Bilinear interpolation is done in the same manner as in regrid_to_refmap.pro
;
;
;
; HISTORY
; 2025-11-19		JD		written
;					& renamed the other method to REGRID_TO_REFMAP.pro
;


NMAP		= n_elements(maps_in.id)

if NOT(keyword_set(XC)) then XC = average(maps_in.xc)
if NOT(keyword_set(YC)) then YC	= average(maps_in.yc)
if keyword_set(zeroXC) then  XC = 0d
if keyword_set(zeroYC) then  YC = 0d
if NOT(keyword_set(DX)) then DX = average(maps_in.dx)
if NOT(keyword_set(DY)) then DY	= average(maps_in.dy)
if not(keyword_set(NX)) then NX = n_elements(maps_in[0].data[*,0])
if not(keyword_set(NY)) then NY = n_elements(maps_in[0].data[0,*])

NXin		= n_elements(maps_in[0].data[*,0])
NYin		= n_elements(maps_in[0].data[0,*])

XC		= double(XC)
YC		= double(YC)
DX		= double(DX)
DY		= double(DY)
NX		= long(NX)
NY		= long(NY)

xind		= indgen(NX)
yind		= indgen(NY)


; create grid
xgrid		= dblarr(NX)
ygrid		= dblarr(NY)

if (NX mod 2 EQ 0) then begin
  for i=0, NX-1 do xgrid[i] = XC -NX/2.*DX +DX/2. +DX*i
endif else begin
  for i=0, NX-1 do xgrid[i] = XC -NX/2 *DX +DX*i
endelse

if (NY mod 2 EQ 0) then begin
  for i=0, NY-1 do ygrid[i] = YC -NY/2.*DY +DY/2. +DY*i
endif else begin
  for i=0, NY-1 do ygrid[i] = YC -NY/2 *DY +DY*i
endelse


xcoord		= dblarr(NX,NY)
ycoord		= dblarr(NX,NY)

for iy=0, NY-1 do xcoord[*,iy] = xgrid
for ix=0, NX-1 do ycoord[ix,*] = ygrid




; make placeholder
out_maps	= replicate({data:fltarr(NX,NY), XC:XC, YC:YC, DX:DX, DY:DY, id:'', time:'', roll_angle:0d, roll_center:[0d, 0d], dur:0d, $
	                     xunits:'arcsec', yunits:'arcsec', soho:0d, L0:0d, B0:0d, Rsun:0d}, NMAP)

if tag_exist(maps_in, 'ODUR')  then out_maps = add_tag(out_maps, maps_in.odur, 'ODUR')



; regrid maps
for imap=0, NMAP-1, 1 do begin

  ; keep as is
  out_maps[imap].id		= maps_in[imap].id
  out_maps[imap].time		= maps_in[imap].time
  out_maps[imap].dur		= maps_in[imap].dur
  out_maps[imap].roll_angle	= maps_in[imap].roll_angle
  out_maps[imap].roll_center	= maps_in[imap].roll_center
  out_maps[imap].B0		= maps_in[imap].B0
  out_maps[imap].L0		= maps_in[imap].L0
  out_maps[imap].Rsun		= maps_in[imap].Rsun
  
  if (out_maps[imap].roll_angle NE 0d) then $
  print,  '-!- REGRID_MAPS:  imap = '+trim(imap)+'  ROLL_ANGLE not zero: ', out_maps[imap].roll_angle, $
   	 +'   ==> IGNORING AT YOUR PERIL'

    
  ; regrid
  get_map_coord, maps_in[imap], xcoord_in, ycoord_in

  ; assume rotation angle is the same 
  ; (otherwise this will need to be programmed)
  
  xind_regrid		= interpol(indgen(NXin), reform(xcoord_in[*,0]), xgrid)
  yind_regrid		= interpol(indgen(NYin), reform(ycoord_in[0,*]), ygrid)
  
  NXind_regrid		= n_elements(xind_regrid)
  NYind_regrid		= n_elements(yind_regrid)
  
  xind_regrid_array	= dblarr(NXind_regrid, NYind_regrid)
  yind_regrid_array	= dblarr(NXind_regrid, NYind_regrid)
  
  for iy=0, NYind_regrid-1 do xind_regrid_array[*,iy] = xind_regrid
  for ix=0, NXind_regrid-1 do yind_regrid_array[ix,*] = yind_regrid

  ; finally interpolate the maps
  ; only where there is overlap between the grids
  out_maps[imap].data	= bilinear(maps_in[imap].data, xind_regrid_array, yind_regrid_array, missing=0.)

endfor




return, out_maps
END
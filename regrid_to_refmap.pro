FUNCTION REGRID_TO_REFMAP, maps, ref_map=ref_map


; REGRID_TO_REFMAP
; regrids maps to a common grid given by the ref_map



; HISTORY
; 2025-06-18		JD	created
; 2025-11-19		JD	renamed
; 2026-01-15		JD	changed ref_map to reference_map in the body of the code to not overwrite the input


NMAP		= n_elements(maps.id)
NMAPref		= n_elements(ref_map.id)

if (NMAPref GT 1) then begin
  print, '-!- REGRID_TO_REFMAP: Reference map is an array, using first one'
  reference_map	= ref_map[0]
endif else begin
  reference_map	= ref_map[0]
endelse  




NX		= n_elements(maps[0].data[*,0])
NY		= n_elements(maps[0].data[0,*])

xind		= indgen(NX)
yind		= indgen(NY)

NXref		= n_elements(reference_map.data[*,0])
NYref		= n_elements(reference_map.data[0,*])



get_map_coord, reference_map, xcref, ycref

out_maps	= replicate(reference_map, NMAP)

if tag_exist(maps[0], 'ODUR') and not(tag_exist(reference_map, 'ODUR')) then begin
  out_maps	= add_tag(out_maps, maps.odur, 'ODUR')
endif


for imap=0, NMAP-1, 1 do begin

  out_maps[imap].time		= maps[imap].time
  out_maps[imap].id		= maps[imap].id
  out_maps[imap].dur		= maps[imap].dur
  out_maps[imap].xunits		= maps[imap].xunits
  out_maps[imap].yunits		= maps[imap].yunits
  out_maps[imap].roll_angle	= maps[imap].roll_angle
  out_maps[imap].roll_center	= maps[imap].roll_center

  if (maps[imap].roll_angle NE reference_map.roll_angle) then $
    print, '-!- REGRID_TO_REFMAP:  imap = '+trim(imap)+'  ROLL_ANGLE not equal. Ref_map: ', reference_map.roll_angle, '  map['+trim(imap) $
           +']: ', maps[imap].roll_angle, '     ==> IGNORING AT YOUR PERIL'
    
  
  get_map_coord, maps[imap], xcoord, ycoord

  ; assume rotation angle is the same 
  ; (otherwise this will need to be programmed)
  
  xindref	= interpol(xind, reform(xcoord[*,0]), reform(xcref[*,0]))
  yindref	= interpol(yind, reform(ycoord[0,*]), reform(ycref[0,*]))
  
  NXindref	= n_elements(xindref)
  NYindref	= n_elements(yindref)
  
  xindref_array	= dblarr(NXindref, NYindref)
  yindref_array	= dblarr(NXindref, NYindref)
  
  for iy=0, NYindref-1 do xindref_array[*,iy] = xindref
  for ix=0, NXindref-1 do yindref_array[ix,*] = yindref

  ; finally interpolate the maps
  ; only where there is overlap between the grids
  out_maps[imap].data	= bilinear(maps[imap].data, xindref_array, yindref_array, missing=0.)
endfor

return, out_maps

END
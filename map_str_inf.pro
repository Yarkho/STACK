; 2019-01-28
; for automatic identification of maps when plotting images
; only deconvolved maps implemented so far


; HISTORY
; 2019-02-20		JD		- added RD and LRR Maps
; 2024-10-03		JD		- added CID
; 					- added Fe XVIII proxy
; 2024-11-12		JD		- overhaul

FUNCTION map_str_inf, map

	; deconvolved maps
	if (tag_exist(map, 'img_proc')) then begin
	   if (map.img_proc EQ 'Approximate PSF deconvolved - psf_deconvol.pro') then str_inf = ' DCV   '
	endif else begin
	  str_inf	= '   '
	endelse

	if (tag_exist(map, 'id_ext')) then begin
	
	   ; running difference maps
	   if (strmid(map.id_ext, 0, 5)  EQ 'RDIFF')  	    	then str_inf = ' RD  '
	   if (strmid(map.id_ext, 0, 12) EQ 'RDIFF 12-sec') 	then str_inf = ' RD 12s  '
	   if (strmid(map.id_ext, 0, 12) EQ 'RDIFF 48-sec') 	then str_inf = ' RD 48s  '
	   if (strmid(map.id_ext, 0, 12) EQ 'RDIFF 72-sec') 	then str_inf = ' RD 72s  '

      	   ; log running ratio maps
	   if (strmid(map.id_ext, 0, 3) EQ 'LRR')        	then str_inf = ' LRR  '
	   if (strmid(map.id_ext, 0, 9) EQ 'LRR 12-sec') 	then str_inf = ' LRR 12s  '
	   if (strmid(map.id_ext, 0, 9) EQ 'LRR 48-sec')	then str_inf = ' LRR 48s  '
	   if (strmid(map.id_ext, 0, 9) EQ 'LRR 72-sec')	then str_inf = ' LRR 72s  '

	   ; Combined Improved Difference (CID) maps
	   if (strmid(map.id_ext, 0, 7)  EQ 'CI DIFF')        	then str_inf = ' CID  '
	   if (strmid(map.id_ext, 0, 14) EQ 'CI DIFF 12-sec') 	then str_inf = ' CID 12s  '
	   if (strmid(map.id_ext, 0, 14) EQ 'CI DIFF 48-sec') 	then str_inf = ' CID 48s  '
	   if (strmid(map.id_ext, 0, 14) EQ 'CI DIFF 72-sec') 	then str_inf = ' CID 72s  '

	   ; Fe XVIII proxy
	   if (strmid(map.id_ext, 0, 14) EQ 'Fe XVIII proxy')  	then str_inf = ' Fe XVIII  '
	endif else begin
	  str_inf	= '   '
	endelse
	
return, str_inf
END

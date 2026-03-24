; INPUT	
; output of find_files  -or-  file_search
;
; OUTPUT
;
;
; PURPOSE
; to get info about AIA files & their completeness without reading them



; 2021-10-14	JD	written
; 2021-10-15	JD	finished; added PSYM
; 2021-11-03	JD	adapted for ROB filenames
;			
;			JSOC filenames:  aia_lev1_304a_2012_04_16t21_59_32_12z_image_lev1.fits
;			 ROB filenames:  aia_20120416_160724_0211_image_lev1.fits
;
; 2021-11-04	JD	added CHARSIZE 
; 2022-05-02	JD	added old JSOC names (aia.lev1. ...)
; 2022-09-06	JD	corrected for JSOC filenames / 94a: minus was not implemented

; 2022-11-03	JD	added HMI
; 2024-01-23	JD	added MIN_TIME, MAX_TIME, YMINOR
; 2025-06-06	JD	added INTERVAL
; 2025-10-14	JD	changed YMINOR to TMINOR
; 2025-11-20	JD	added EUI

PRO plot_file_deriv, files, date, time, out, psym=psym, charsize=charsize, min_time=min_time, max_time=max_time, yminor=yminor, tminor=tminor, interval=interval;, jsoc=jsoc, rob=rob


NF		= n_elements(files)
source		= strarr(NF)
date		= strarr(NF)
time		= strarr(NF)
filter		= strarr(NF)
out		= strarr(NF)

len		= strlen(files[0])
ll		= intarr(NF)

if not(keyword_set(psym)) then psym=1
if not(keyword_set(tminor)) then tminor=5

if not(keyword_set(charsize)) then begin
  dim		= get_screen_size()
  if (dim[1] LE 1281) then charsize=1.25 else charsize=1.75
endif

if keyword_set(interval) then ytickinterval = interval


for jf=0, NF-1, 1 do begin

  ; determine filter
  for ilen=0, len-5, 1 do begin

    str		= strmid(files[jf], ilen, 5)
    ; 0094, 1600, and 1700 to be tested if ROB filenames
    if (strmid(str, 0, 3) EQ '94a')  or (strmid(str, 0, 3) EQ '94A')  or (strmid(str, 0, 4) EQ '0094') then filter[jf]='94' 
    if (strmid(str, 0, 4) EQ '131a') or (strmid(str, 0, 4) EQ '131A') or (strmid(str, 0, 4) EQ '0131') then filter[jf]='131' 
    if (strmid(str, 0, 4) EQ '171a') or (strmid(str, 0, 4) EQ '171A') or (strmid(str, 0, 4) EQ '0171') then filter[jf]='171' 
    if (strmid(str, 0, 4) EQ '193a') or (strmid(str, 0, 4) EQ '193A') or (strmid(str, 0, 4) EQ '0193') then filter[jf]='193' 
    if (strmid(str, 0, 4) EQ '211a') or (strmid(str, 0, 4) EQ '211A') or (strmid(str, 0, 4) EQ '0211') then filter[jf]='211' 
    if (strmid(str, 0, 4) EQ '304a') or (strmid(str, 0, 4) EQ '304A') or (strmid(str, 0, 4) EQ '0304') then filter[jf]='304' 
    if (strmid(str, 0, 4) EQ '335a') or (strmid(str, 0, 4) EQ '335A') or (strmid(str, 0, 4) EQ '0335') then filter[jf]='335' 
    if (str EQ '1600a') or (str EQ '1600A') or (strmid(str, 0, 4) EQ '1600') then filter[jf]='1600'
    if (str EQ '1700a') or (str EQ '1700A') or (strmid(str, 0, 4) EQ '1700') then filter[jf]='1700'
    if (str EQ 'hmi_m') then filter[jf]='HMI'
  endfor
  
  ; determine file source
  for ilen=0, len-6, 1 do begin
    ;delvarx, ll
    str		= strmid(files[jf], ilen, 6)
    if (str EQ 'aia_le') then begin & 	source[jf] = 'JSOC'		& ll[jf] = ilen	+14	& endif
    if (str EQ 'aia.le') then begin & 	source[jf] = 'JSOC NORICE'	& ll[jf] = ilen	+14	& endif
    if (str EQ 'aia_20') then begin & 	source[jf] = 'ROB'		& ll[jf] = ilen		& endif
    if (str EQ 'hmi_m_') then begin &	source[jf] = 'JSOC'		& ll[jf] = ilen	+10	& endif			; placeholder
  endfor

  
  ; now we need the output, including date and time
  ; do that separately depending on the source of the file
  
  ; JSOC filenames:  
  if (source[jf] EQ 'JSOC') or (source[jf] EQ 'JSOC NORICE') then begin 
    ;if (filter[jf] EQ '94') then minus = 2
    ;if (filter[jf] EQ '131') or (filter[jf] EQ '171') or (filter[jf] EQ '193') or (filter[jf] EQ '211') or $
       ;(filter[jf] EQ '304') or (filter[jf] EQ '335') then minus=1
    ;if (filter[jf] EQ '1600') or (filter[jf] EQ '1700') then minus=0
    if (filter[jf] EQ '94') then minus = 1
    if (filter[jf] EQ '131') or (filter[jf] EQ '171') or (filter[jf] EQ '193') or (filter[jf] EQ '211') or $
       (filter[jf] EQ '304') or (filter[jf] EQ '335') then minus=0
    if (filter[jf] EQ '1600') or (filter[jf] EQ '1700') then minus=-1
    if (filter[jf] EQ 'HMI') then minus=0										; placeholder

    ;stt		= strmid(files[jf], 53-minus, 22)
    stt		= strmid(files[jf], ll[jf]-minus, 22)
    date[jf]	= strmid(stt, 0, 4)+'-'+strmid(stt, 5, 2)+'-'+strmid(stt, 8, 2)
    if not(filter[jf] EQ 'HMI') then begin
      time[jf]	= strmid(stt, 11, 2)+':'+strmid(stt, 14, 2)+':'+strmid(stt, 17, 2)+'.'+strmid(stt, 20, 2)
    endif else begin
      time[jf]	= strmid(stt, 11, 2)+':'+strmid(stt, 14, 2)+':'+strmid(stt, 17, 2);+'.'+strmid(stt, 20, 2)
    endelse

    out[jf]	= anytim(date[jf]+'T'+time[jf], out_style='vms')
    
    ;print, filter[jf], '	', stt, '	', date[jf], '	', time[jf], '	', out[jf]
  endif
  
  
  ; ROB filenames
  ; these seem to have fixed number of characters, so things are easier here
  if (source[jf] EQ 'ROB') then begin
    stlen	= strlen(files[jf])
    date[jf]	= strmid(files[jf], stlen-36, 4)+'-'+strmid(files[jf], stlen-32, 2)+'-'+strmid(files[jf], stlen-30, 2)
    time[jf]	= strmid(files[jf], stlen-27, 2)+':'+strmid(files[jf], stlen-25, 2)+':'+strmid(files[jf], stlen-23, 2)
    out[jf]	= anytim(date[jf]+'T'+time[jf], out_style='vms')
  endif
  
  
  ; EUI
  for ilen=0, len-34, 1 do begin
    str = strmid(files[jf], ilen, 34)
    if (str EQ 'solo_L2_eui-hrieuv174-image-short_') 	then begin 	& filter[jf]='174 short' 	& ll[jf] = ilen +34 	& endif
  endfor
  for ilen=0, len-28, 1 do begin
    str = strmid(files[jf], ilen, 28)
    if (str EQ 'solo_L2_eui-hrieuv174-image_') 		then begin	& filter[jf]='174' 		& ll[jf] = ilen +28 	& endif
  endfor
  
    
  if (filter[jf] EQ '174') or (filter[jf] EQ '174 short') then begin
    stt		= strmid(files[jf], ll[jf], 18)
    ; print, stt
    ; stop
    date[jf]	= strmid(stt, 0, 4)+'-'+strmid(stt, 4, 2)+'-'+strmid(stt, 6, 2)
    time[jf]	= strmid(stt, 9, 2)+':'+strmid(stt, 11, 2)+':'+strmid(stt, 13, 2)+'.'+strmid(stt, 15, 3)
    ; print, date[jf]
    ; print, time[jf]
    ; stop
    out[jf]	= anytim(date[jf]+'T'+time[jf], out_style='vms')
    ; print, out[jf]
    ; stop
  endif
	  
endfor




yt_profile	= {yplot:intarr(NF), dy:1d, y_units:'seconds', dt:1d-2, tcoord:out}
; yt_profile.yplot= replicate(1, NF)
yt_profile.yplot= deriv( (anytim2utc(out)).time)/1d3

plot_timeplot, 	yt_profile, /transpose, yrange=[1, 300], /ylog, psym=psym, min_time=min_time, max_time=max_time, $
		xtitle='Difference between frames [seconds]', title=filter[0], yminor=tminor, charsize=charsize, $
		ytickinterval=ytickinterval


END

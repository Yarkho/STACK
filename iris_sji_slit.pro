FUNCTION IRIS_SJI_slit, maps_sji, offset=offset, full=full, sobel_profile=sobel_profile, sobel_x=sobel_x;, boxcar=boxcar


; Returns location of the IRIS slit
; from an array of IRIS/SJI maps


; INPUT
; maps_sji		- map array [NMAP]
;
; OUTPUT
; xslit			- X loci of slit, NMAP elements
;
; OPTIONAL INPUT/OUTPUT
; offset		- (keyword) 		chosen offset (see NOTES) in IRIS _PIXELS_
;
; boxcar		- (keyword, integer)	boxcar size to smooth the IRIS/SJI data with
; full			- (keyword, boolean) 	if set, will output SOBEL_PROFILE and SOBEL_x
; sobel_profile		- (keyword)  		sobel profile of each map
; sobel_x		- (keyword)  		coordinates for SOBEL_PROFILE
;
;
; CALLS
; SOBEL
; get_map_coord
; mean
;
;
; NOTES
; 1. The output is not always trustworthy, as strong brightenings can also produce spurious SOBEL signal
;
; 2. The SOBEL operator will likely detect the right-hand edge of the IRIS slit in the SJI images;
;    proper choice of OFFSET may be necessary.
;
; 3. The program assumes that the SJI data have proper X,Y coordinates (no roll).
;    If your coordinates are rolled, the output will be in the rolled X coordinate;
;      that is, not in Solar X


;
; HISTORY
; 2024-10-09		JD		- written
;
;
;


; copy the input maps
if NOT(keyword_set(boxcar)) then boxcar=1

if NOT(keyword_set(offset)) then begin
  print, '% IRIS_SJI_SLIT: Offset not set, perhaps consider -3 IRIS pixels (-0.5")?'
  offset 	= 0.
endif


sobelsji	= maps_sji

NX		= n_elements(maps_sji[0].data[*,0])
NY		= n_elements(maps_sji[0].data[0,*])
NMAP		= n_elements(maps_sji.id)

avg		= dblarr(NMAP, NX)
xiris		= dblarr(NMAP, NX)
yiris		= dblarr(NMAP, NY)

xslit		= dblarr(NMAP)

; for i=0, NMAP-1 do sobelsji[i].data = sobel(smooth(maps_sji[i].data, boxcar)^1.0)
for i=0, NMAP-1 do sobelsji[i].data = sobel((maps_sji[i].data)^1.0)


for imap=0, NMAP-1, 1 do begin

  get_map_coord, maps_sji[imap], xcoord, ycoord
  xiris[imap,*]	= reform(xcoord[*,0])
  yiris[imap,*]	= reform(ycoord[0,*])

 for ix=0, NX-1, 1   do begin
   avg[imap,ix] = mean(sobelsji[imap].data[ix,*])
 endfor
 
  ; get rid of NaNs
  inan		= where(finite(avg[imap,*]) EQ 0)
  ; print, imap, inan
  ; stop
  avg[imap,inan]= 0d
    
  ; get rid of maxima at the edges of IRIS/SJI FOV
  dummy		= max(avg[imap, NX/5 : 4*NX/5], IXC)
  xslit[imap]	= xiris[imap, IXC +NX/5] +offset*maps_sji[imap].dx
endfor


if keyword_set(full) then begin
  sobel_profile	= avg
  sobel_x	= xiris
endif
  
return, xslit
END
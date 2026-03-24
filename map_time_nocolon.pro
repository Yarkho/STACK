; returns map time without colons - for image saving


; 2018-10-17		JD
; 2019-02-13		JD		- added functionality for direct map input




function MAP_TIME_NOCOLON, input

  if (valid_map(input)) then time	= input[0].time	$
			else time	= input[0]

  tt	= anytim(time, out_style='vms')
  tt	= strmid(tt, 12, 8)
  out	= strmid(tt, 0, 2) +strmid(tt, 3, 2) + strmid(tt, 6, 2)


return, out
END

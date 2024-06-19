dList

;	.by	$70,$70,$30
;	.by	$44,.lo(tileMapAdr),.hi(tileMapAdr)
;	.by	$04,$84,$04,$04,$84,$04,$04,$84
;	.by	$04,$04,$84,$04,$04,$84,$04,$04
;	.by	$84,$04,$04,$84,$04,$04,$84
;	.by	$41,.lo(dList),.hi(dList)

	.by	$70,$B0,$70
tileMapPtr = * + 1
	.by	$44,.lo(tileMapLAdr),.hi(tileMapLAdr)
	.by	$04,$04,$04,$04,$04,$04,$04,$04
	.by	$04,$04,$04,$04,$04,$04,$04,$04
	.by	$04,$04,$04,$04,$04,$04,$04
	.by	$40
	.by	$52,.lo(scrollMem),.hi(scrollMem)
	.by	$70,$50
anticLock
	.by	$00 ;$00 - normal, $0F - Antic locked
	.by	$41,.lo(dList),.hi(dList)


dListNotReady

	.by	$70,$B0
	.by	$42,.lo(msgNotReady),.hi(msgNotReady)
	.by	$44,.lo(tileMapRAdr),.hi(tileMapRAdr)
	.by	$04,$04,$04,$04,$04,$04,$04,$04
	.by	$04,$04,$04,$04,$04,$04,$04,$04
	.by	$04,$04,$04,$04,$04,$04,$04
	.by	$40
	.by	$52,.lo(scrollMem),.hi(scrollMem)
	.by	$41,.lo(dListNotReady),.hi(dListNotReady)

msgNotReady
	dta d'  Graphic chips not ready for DGF/DGI!  '

dListEmpty
	.by	$41,.lo(dListEmpty),.hi(dListEmpty)

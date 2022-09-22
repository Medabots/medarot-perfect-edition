[map all main.kabuto.map]
; A complete listing of data in the ROM, used as a way to 'link' the final output

; FIXME: Figure out how to use the metadata labels to auto-generate the math in this line
INCBIN "baserom_kabuto.ws", 0x00, (1 * 1024 * 1024) - (5) - (1) - (10)

; FIXME: Auto-generate metadata in script
; FIXME: Create macro to validate sizes
_init_start:
INCBIN "./build/core.init.bin"
_init_end:

db 0x00 ; Metadata must always be preceded by a 0

_metadata_start:
; Metadata at the end of the file
db 0x11 ; Publisher: Imagineer
db 0x00 ; System: WonderSwan
db 0x01 ; GameID : 01
db 0x00 ; Game Revision: 00
db 0x03 ; ROM Size: 8MBit (1MB)
db 0x02 ; Save Size/Type: 256KBit SRAM (32KB)
db 0b100 ; Flags: (Rom Access Speed: 1 Cycle) | (ROM Bus Width: 16-bit) | (Orientation: Horizontal)
db 0x00 ; RTC: False
db 0x35, 0x20 ; Checksum
_metadata_end:

%if _metadata_end - _metadata_start != 10
%error "Invalid metadata length"
%endif
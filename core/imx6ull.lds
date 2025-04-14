
ENTRY(_start)
SECTIONS{
	. = 0X87800000;
	.text :
	{
    KEEP(*(.text._start))
		*(.text)
	}
  .note.gnu.build-id : {
        *(.note.gnu.build-id) /* 将 .note.gnu.build-id 放在其他段之后 */
  }
	.rodata ALIGN(4) : {*(.rodata*)}     
	.data ALIGN(4)   : { *(.data) }    
	__bss_start = .;    
	.bss ALIGN(4)  : { *(.bss)  *(COMMON) }    
	__bss_end = .;
}
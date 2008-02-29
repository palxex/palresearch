
PAGE  59,132

;==========================================================================
;==					                                 					 ==
;==				PLAYRIX	                                 				 ==
;==					                                 					 ==
;==      Created:   2-Jul-94		                                 	 ==
;==      Passes:    9          Analysis	Options on: FGHILO               ==
;==					                                 					 ==
;==========================================================================



.386c


Adlib_port	equ	 0C1Ah
music_pass	equ  388h			

;------------------------------------------------------------  code_seg   ----

code_seg		segment	byte public use16
		assume cs:code_seg  , ds:data_seg , ss:stack_seg


;==========================================================================
;
;                       Program	Entry Point
;
;==========================================================================


start:
playrix			proc	far


		mov	bx,7A0h							; 一直以为这里没有用，其实后面的许多信息都存入了这个新加的空间
		mov	ah,4Ah
		int	21h								; DOS Services  ah=function 4Ah
											; change memory allocation
											; bx=bytes/16, es=mem segment
		jnc	short loc_1						; Jump if carry=0
		jmp	_exit							; 退出程序
loc_1:
		mov	ax,data_seg
		mov	ds,ax							; 分配数据段
		
		mov	dx,offset _title				; ('PlayRix Version 1.01 ](T')
		mov	ah,9
		int	21h								; DOS Services  ah=function 09h
											;  display char string at ds:dx
		call	input_check					; 看有没有文件参数输入
		cmp	byte ptr data_78,0
		je	short file_got					; Jump if equal
		mov	ah,9
		mov	dx,offset usage					; 没有参数输入，提示正确用法并退出程序。
		int	21h								; DOS Services  ah=function 09h
											;  display char string at ds:dx
		mov	ah,4Ch
		int	21h								; DOS Services  ah=function 4Ch
											;  terminate with al=return code

file_got:									; 有正确的文件参数输入
		call	malloc						; 申请内存空间，首地址保存于buf_addr
		call	init						; 读入文件，做好了预备工作
		call	set_new_int					; 更新了时钟中断向量
		push 	music_pass					; 播放音乐的趟数				
		call	save_parm					; 设置音乐的播放次数
		add sp,2							; 丢弃参数，恢复堆栈
		mov	bx,buf_addr
		xor	cx,cx				
		mov	dx,mus_time
		call	data_prepare				; 准备并整理rix文件的数据
key_check   proc  near						; 按键输入检测
		mov	ah,2
		int	16h						; Keyboard i/o  ah=function 02h
									;  get shift status in al
		and	al,4
		cmp	al,4					; 如果Ctrl 键按下
		je	short ctrl_pres			
		mov	ah,1
		int	16h						; Keyboard i/o  ah=function 01h
									;  get status, if zf=0  al=char
		jz	key_check				; Jump if zero
		mov	ah,0
		int	16h						; Keyboard i/o  ah=function 00h
									;  get keybd char in al, ah=scan
		cmp	al,50h					; 如果'P'键按下
		je	short P_pres				
		cmp	al,70h					; 如果'p'键按下
		jne	short smp_pres				
P_pres:
		push	ax
		call	pause
		pop	ax
smp_pres:
		cmp	al,43h					; 'C'
		je	short C_pres				
		cmp	al,63h					; 'c'
		jne	short smc_pres				; Jump if not equal
C_pres:
		push	ax
		call	zero_0C62h
		pop	ax
smc_pres:
		cmp	al,2Dh					; '-'
		jne	short sub_pres				
		add	mus_time,32h
		cmp	mus_time,7000h
		jbe	short loc_8				; Jump if below or =
		mov	mus_time,7000h
loc_8:
		mov	ax,mus_time
		call	set_timer
sub_pres:
		cmp	al,2Bh					; '+'
		jne	short plu_pres			
		sub	mus_time,32h
		cmp	mus_time,1000h
		jae	short loc_10			; Jump if above or =
		mov	mus_time,1000h
loc_10:
		mov	ax,mus_time
		call	set_timer
plu_pres:
		jmp	short key_check
		
			                    
ctrl_pres:
		push 0
		call	save_parm
		add sp,2
		call	fr_use_reg
		call	set_old_int
		mov	ax,4C00h				; 退出程序
		int	21h		
		db	16	dup(0)				
key_check  		endp									
			
playrix		endp

set_timer		proc	near				; 设置8253 定时器
;==========================================================================
;                              设置8253定时器
;==========================================================================
		push	ax
		push	ax
		cli							; Disable interrupts
		mov	al,36h					; '6'
		out	43h,al					; port 43h, 8253 timer control
		pop	ax
		out	40h,al					; port 40h, 8253 timer 0 clock
		xchg	ah,al
		out	40h,al					; port 40h, 8253 timer 0 clock
		xchg	ah,al
		sti							; Enable interrupts
		pop	ax
		ret							; 原来为retn
			                        
set_timer		endp

input_check		proc	near				; 大概是检测有无文件参数输入
;==========================================================================
;                            检测有无文件参数输入
;==========================================================================
		push	di
		mov	di,80h		
		xor	cx,cx					; Zero register
		mov	cl,es:[di]
		inc	di
		mov	byte ptr data_78,0
		or	cx,cx					; 
		jz	short loc_13			; Jump if zero
		cmp	cx,14h
		jbe	short loc_14			; Jump if below or =
loc_13:
		mov	byte ptr data_78,1
		jmp	short loc_18
loc_14:
		mov	bx,offset data_70
		xor	ax,ax					; Zero register

locloop_15:
		mov	al,es:[di]
		cmp	al,20h					; ' '
		je	short loc_16			; Jump if equal
		mov	[bx],al
		inc	bx
loc_16:
		inc	di
		loop	locloop_15			; Loop if cx > 0

		push	es
		push	ds
		pop	es
		mov	di,offset in_filename
		mov	cx,5

locloop_17:
		mov	al,es:[di]
		mov	[bx],al
		inc	bx
		inc	di
		loop	locloop_17			; Loop if cx > 0

		pop	es
loc_18:

		pop	di
		retn
			                      
input_check		endp

init			proc	near				; 将文件读入前面申请的缓冲区，并将ds 的值赋给es。
;==========================================================================
;                              初始化工作
;==========================================================================
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds
		push	es
		push	ds				; 这里应该是用来把ds 的值给es
		pop	es

		mov	cx,0FFFFh			; 设置读取长度
		mov	dx,0
		call	fopen			; 打开文件，句柄保存在bx
		mov	ds,buf_addr			; 将先前申请的缓冲区首址给ds

		xor	dx,dx				; Zero register
		call	file_to_buf		; 将文件读入缓冲区
		call	fclose			; 关闭文件
		pop	es
		pop	ds					; ds已经恢复，指向原来的数据段
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		retn
			                        
init		endp

malloc			proc	near				; 分配存储空间
;==========================================================================
;                              分配存储空间
;==========================================================================
		push	ax
		push	bx
		mov	ah,48h				
		push	ax
		mov	bx,1000h				; 分配了64k 共一个段的空间，奇怪的是，这里即使是0也行。
		int	21h						; DOS Services  ah=function 48h
									;  allocate memory, bx=bytes/16
		jnc	short loc_19			; Jump if carry=0
		jmp	short _exit				; 如果申请失败，退出
			                        ; now data because: after jmp/ret
loc_19:								; 申请成功
		mov	buf_addr,ax				; 将申请成功的首地址保存在buf_addr
		pop	ax
		pop	bx
		pop	ax
		retn
 		db  22 dup(0)				; 垃圾填充定位	
malloc	endp 		

fopen       	proc	near				; 打开文件

		mov	ax,3D02h				; 以读/写方式打开文件
		int	21h						; DOS Services  ah=function 3Dh
									;  open file, al=mode,name@ds:dx
		jc	short _exit				; Jump if carry Set 失败则退出程序
		mov	bx,ax					; 文件句柄保存在bx
		retn
fopen      endp		

file_to_buf		proc    near 				; 将文件读入指定的缓冲区

		mov	ah,3Fh
		int	21h						; DOS Services  ah=function 3Fh
									;  read file, bx=file handle
									;   cx=bytes to ds:dx buffer
		jc	short _exit				; 失败则退出
		retn
		db	7 dup(0)				; 垃圾填充定位
file_to_buf		endp		
	                       		
fclose			proc    near				; 关闭文件
		mov	ah,3Eh
		int	21h						; DOS Services  ah=function 3Eh
									;  close file, bx=file handle
		jc	short _exit				; 失败则退出
		retn
fclose		endp		
			                       			                        
_exit 			proc	near				; 退出程序
		mov	ax,4C01h
		int	21h		
		db	227	dup(0h) 
_exit		endp	

pause			proc	near				; 暂停音乐
;==========================================================================
;                              SUBROUTINE
;==========================================================================
		push	si						; 保存si
		mov	word ptr ds:[0C62h],1		; 往ds:[0C62h] 的内存里写入一个字的1。
		sub	si,si						; 清零si
loc_21:
		push	si						; PARAMETER_1
		call	switch_ad_bd
		add	sp,2
		inc	si
		cmp	si,0Bh
		jl	loc_21						; Jump if <
		pop	si
		retn
			                        
pause		endp

zero_0C62h		proc	near				; 将ds:[0C62h] 处的数据清零
		mov	word ptr ds:[0C62h],0
		retn
zero_0C62h		endp

save_parm		proc	near				; 将0保存在ds:[0C5Ch]处	

		push	bp
		mov	bp,sp
		mov	ax,[bp+4]						; 第一个参数给ax，如果直接给0值，音乐将只播放一遍？	
		mov	ds:[0C5Ch],ax					; 参数保存在ds:[0C5Ch] 处
		leave								; 恢复各个寄存器
		retn
		db	8 dup(90h)
save_parm		endp

set_new_int		proc	near			                        
		push	388h				; PARAMETER_1 声卡端口号进栈
		call	ad_init
		add	sp,2
		or	ax,ax					; 
		jz	short loc_ret			; 当ax 为0 时返回
		call	step
		mov	ax,1
loc_ret:
		retn
set_new_int		endp		
			                       
set_old_int		proc	near			                        
		jmp    set_int
		nop        
set_old_int		endp		

data_prepare	proc	near				; 仅仅开始的时候被调用了一次。
;==========================================================================
;                     重要函数！无参，也只被调用了一次！
;==========================================================================

		push	di
		mov	di,0							; 
		mov	ax,4268h						; 缺省音乐速率	
		mov	ds:[0C60h],ax					; 音乐速率送ds:[0C60h]，当一遍播完后，再次读取这个值
		mov	ax,buf_addr						; rix文件缓冲区地址送ax
		mov bx,0
		mov	ds:[0C64h],bx					; 可以直接给0 值
		mov	ds:[0C66h],ax					; rix文件缓冲区地址送ds:[0C66h]，显然是保存用。
		mov	es,ax							; rix文件缓冲区地址送es，显然是解压用。
		mov	ch,es:[di+0Dh]					; rix文件的0Dh 字节处的信息送ch
		mov	dl,es:[di+0Ch]					; rix文件的0Ch 字节处的信息送dl
		mov	bl,dl							; 保存dl 到bl
		mov	bh,ch							; 保存ch 到bh，从而将rix文件的0C、0D 字节内容组合到bx里面
		mov	cx,buf_addr						; rix文件缓冲区地址送cx
		mov	ds:[0C40h],bx					; 将rix文件的“CD”信息保存在ds:[0C40h]处
		mov	word ptr ds:[0C42h],cx			; 将rix文件缓冲区地址保存在ds:[0C42h]处，但是好像保存在哪里并不重要？
		mov	ds:[0C46h],bx					; 将rix文件的“CD”信息保存在ds:[0C46h]处，如果这里不保存，将不能循环
		mov	ds:[0C48h],cx					; 将rix文件的缓冲区地址保存在ds:[0C48h]处
		mov	ch,es:[di+9]					; rix文件9字节开始，1个字节的数据送ch
		mov	dx,ax							; rix文件缓冲区地址送dx
		mov	cl,es:[di+8]					; rix文件8 字节开始，1个字节的数据送bl
		mov	ds:[0C6Ah],cx					; 算出的结果保存在ds:[0C6Ah]处。
		mov	word ptr ds:[0C6Ch],ax			; 将rix文件缓冲区地址送ds:[0C6Ch] 的地方。
		mov di,0
		mov	ds:[0C4Eh],di					; 填零
		mov	ds:[0C4Ch],di					; 填零
		mov	al,es:[di+2]					; 将rix文件的第三个字节处的内容送al
		sub	ah,ah							; 清零ah，组合出ax
		push	ax							; PARAMETER_1
		call	ser_reg_op					; 一系列调用后，生成了一个wave，非常关键的一步。
		call	only_one					; 调用那个无参函数，为的就是设置内存里的两个值。
		add	sp,2
		push	4268h						; 缺省速率
		call	call_settime				; 实际上是设置了系统时钟
		add	sp,2
		mov	word ptr ds:[0C68h],0
		mov	byte ptr ds:[0C45h],1
		pop	di
		retn
		db	59	dup(0h)	                    
data_prepare		endp

fr_use_reg		proc	near				; 

		push	si
		mov	byte ptr ds:[0C45h],0			; 将ds:[0C45h] 处的数据（字节）设置为0
		sub	si,si							; 清零si
loc_25:
		push	si							; PARAMETER_1
		call	switch_ad_bd
		add	sp,2
		inc	si
		cmp	si,0Bh
		jl	loc_25							; Jump if <
		push	1							; PARAMETER_2
		push	0							; PARAMETER_1
		call	two_call_fr
		add	sp,4
		pop	si
		retn
		nop	                        
fr_use_reg		endp

two_call_fr		proc	near				;

PARAMETER_1	=	4							; bp+4
PARAMETER_2	=	6							; bp+6

		push	bp
		mov	bp,sp
		push	di
		push	si
		push	0							; PARAMETER_4
		push	3Ch							; PARAMETER_3
		mov	ax,[bp+PARAMETER_2]
		mul	word ptr [bp+PARAMETER_1]		; dx:ax = 参数1 × 参数2
		push	dx							; PARAMETER_2
		push	ax							; PARAMETER_1
		call	fourier_maybe
		mov	di,ax
		or	di,di							; 检测返回值
		jnz	short loc_26					; 返回值不为0
		sub	si,si							; 清零si
		jmp	short loc_27
			                        
loc_26:
		sub	ax,13h
		sbb	cx,cx
		not	cx
		and	ax,cx
		add	ax,13h
		mov	di,ax
		push	0							; PARAMETER_4
		push	di							; PARAMETER_3
		push	12h							; PARAMETER_2
		push	34DCh						; PARAMETER_1
		call	fourier_maybe
		mov	si,ax
loc_27:										; 返回值为0
		push	si							; PARAMETER_1
		call	call_settime
		add	sp,2
		pop	si
		pop	di
		leave								; Procedure exit
		retn

two_call_fr		endp

rix_proc		proc	near				; 仅仅被中断设置函数调用，应该是rix文件的解码函数。
											; 特别注意，此时：数据段、堆栈段，附加段三段合一！都是原来的数据段，且sp为3BAh

LOCAL_2		=	-4				; bp+0FFFCh
LOCAL_1		=	-2				; bp+0FFFEh

		enter	3Ch,0					; Procedure entry
		push	di
		push	si
		cmp	byte ptr ds:[0C45h],0		; 这个好像也是个标志位。
		jne	short start_to_pro			; 如果不是0 的话。
return0:								; 如果是0 返回0 值
		sub	ax,ax
		pop	si
		pop	di
		leave							
		retn
		nop
start_to_pro:
		cmp	word ptr ds:[0C62h],1		; ds:[0C62h] 处的数据似乎是个标志位。
		je	return0						; Jump if equal
		mov	word ptr ds:[0E8h],1
		mov	ax,ds:[0C68h]				; 这个值曾被data_prepare操作过。
		sub	dx,dx
		add	ds:[0C4Ch],ax
		adc	ds:[0C4Eh],dx
		mov	ds:[0C68h],dx
pro_loop:										; 每次步进2个字节，比如，首次指向rix:0114，第二次就是rix:0116了
		les	bx,dword ptr ds:[0C40h]				; ex 现在为rix文件缓冲区的地址，bx 现在装有rix文件的0C、0D字节的内容！（比如0114）
		mov	al,byte ptr es:[bx]					; rix 文件0C、0D 装载的是个地址！每次对它所指的地方进行操作！
		mov	ds:[0C44h],al						; 将rix文件0C、0D所指文件偏移地址处的一个字节的值送ds:[0C44h]，比如，0114处的值为0
		inc	word ptr ds:[0C40h]					; 现在，ds:[0C40h]处存放的是rix文件[0C0D]所指（比如0114）开始偏移1 字节的地址
		mov	bx,ds:[0C40h]						; bx 现在为rix文件0C0D 的内容地址偏移1 字节处的地方（比如0115 处）
		mov	al,es:[bx]							; 例如rix文件0115 处
		inc	word ptr ds:[0C40h]					; 现在，ds:[0C40h] 处存放的是rix文件0C0D开始偏移2 字节的地址
		mov	[bp-1],al							; 保存在LOCAL_1 的高字节
		cmp	al,80h								; 一个拍（我暂时这么叫它）的高字节
		jne	short not_eof						; 重要！好像rix文件是以80h为结尾的！ 
		jmp	is_eof
not_eof:
		and	ax,0Fh								; 只保留最低0-3 位
		mov	di,ax								; 保存之
		mov	al,[bp-1]							; 恢复被and 破坏的数据
		and	ax,0F0h								; 只保留4-7 位
		sub	ax,90h								; 看看等不等于90h
		jz	short is_90h						; 
		sub	ax,10h								; 看看等不等于A0h
		jz	short is_A0h						; 
		sub	ax,10h								; 看看等不等于B0h
		jz	short is_B0h						; 
		sub	ax,10h								; 看看等不等于C0h
		jz	short is_C0h						; 
		mov	al,ds:[0C44h]						; rix文件0C、0D 所指地址处的值，比如rix:0114 = 0
		mov	ah,[bp-1]							; 恢复高字节（例如0115） 处的值
		mov	ds:[0C68h],ax						; 返回这个值（不是90，不是A0……那是什么？）
		jmp	short is_end?
		nop
is_90h:
		mov	al,ds:[0C44h]						; 还原本轮循环得到的值之低字节
		sub	ah,ah								; 清零高字节
		mov	[bp+LOCAL_2],ax						; 保存于局部变量2
		lea	ax,[bp-3Ch]							; 故弄玄虚，其实是个常量37A
		push	37Ah							; PARAMETER_2 不会把？！常量！？原来是ax 的值
		lea	cx,[bp-4]							; 局部变量2 的地址（指针），应该是刚才的值。
		push	3B2h							; PARAMETER_1 = 又是一个常数。
		call	rix_get_ins
		add	sp,4								; 恢复堆栈
		lea	ax,[bp-3Ch]							; 
		push	ax								; PARAMETER_2
		push	di								; PARAMETER_1
		call	prepare_wave
		jmp	short loc_36
			                       
is_A0h:
		mov	al,ds:[0C44h]						; 拍的低字节
		sub	ah,ah
		shl	ax,6								; 左移6 位
		push	ax								; PARAMETER_2
		push	di								; PARAMETER_1 一个拍的高字节的低4 位
		call	rix_A0_pro
		jmp	short loc_36
is_B0h:
		mov	al,ds:[0C44h]
		sub	ah,ah
		push	ax								; PARAMETER_2
		push	di								; PARAMETER_1
		call	rix_B0_pro
		jmp	short loc_36
is_C0h:
		push	di								; PARAMETER_1
		call	switch_ad_bd
		add	sp,2
		mov	al,ds:[0C44h]
		sub	ah,ah
		mov	si,ax
		or	si,si						
		jz	short is_end?						; Jump if zero
		push	si								; PARAMETER_2
		push	di								; PARAMETER_1
		call	rix_C0_pro
loc_36:
		add	sp,4
is_end?:
		cmp	word ptr ds:[0C68h],0				; 循环终止条件！那么，[0C68h] 处存放的有可能是文件长度什么的。
		jne	short returnX						; 如果不是0
		jmp	pro_loop							; 是0 则回头
is_eof:
		call	fr_use_reg
		cmp	word ptr ds:[0C5Ch],0
		jne	short loc_40						; Jump if not equal
		jmp	return0
			                    
loc_40:
		cmp	word ptr ds:[0C5Ch],0FFFFh
		je	short loc_41						; Jump if equal
		dec	word ptr ds:[0C5Ch]
loc_41:
		mov	ax,ds:[0C46h]
		mov	dx,ds:[0C48h]
		mov	ds:[0C40h],ax
		mov	word ptr ds:[0C40h]+2,dx
		push	word ptr ds:[0C60h]				; PARAMETER_1
		call	call_settime
		add	sp,2
		mov	word ptr ds:[0C68h],0
		mov	byte ptr ds:[0C45h],1
		jmp	return0
			                    
returnX:
		mov	word ptr ds:[0E8h],0
		mov	ax,ds:[0C68h]						; ax 为返回值。这个值也曾被data_prepare设置
		pop	si
		pop	di
		leave						
		retn
		db	8	dup(0)
rix_proc		endp

rix_get_ins		proc	near				; 仅仅被rix_proc 调用。全程序唯一的串处理指令在这里
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4			; bp+4					; 参数1 为3B2h
PARAMETER_2	=	6			; bp+6					; 参数2 为一常量37Ah
LOCAL_3		=	-6			; bp+0FFFAh
LOCAL_2		=	-4			; bp+0FFFCh
LOCAL_1		=	-2			; bp+0FFFEh

		enter	6,0			; Procedure entry
		push	di
		push	si
		mov	bx,3B2h									; 原来是参数1 
		mov	ax,[bx]									; 取其值，也就是每一拍的低字节值，怎么是0、1、2 什么的？
		mov	[bp+LOCAL_2],ax							; 保存于局部变量2
		shl	ax,6									; 64 倍
		mov	[bp+LOCAL_3],ax							; 左移6 位后存于局部变量3
		push	cx
		push	di
		push	si
		push	es
		push	ds
		les	si,dword ptr ds:[0C6Ah]					; si为rix文件的8、9 字节信息！es为rix文件首址，例如rix:0014
		add	si,[bp+LOCAL_3]							; 将地址偏移“局部变量3 ”个字节
		mov	cx,es									; 
		push	ds
		pop	es										; es 现在反倒为原来的ds
		mov	di,37Ah									; 原来是取的参数，但是参数好像是常量
		mov	ds,cx									; ds 的值现在为rix文件首址
		mov	cx,1Ch									; 十进制 28	，应该是一个乐器块的长度吧。
		rep	movsw									; Rep when cx >0 Mov [si] to es:[di]，将ins文件解压倒数据区
		pop	ds	
		pop	es
		pop	si
		pop	di
		pop	cx
		pop	si
		pop	di
		leave										; Procedure exit
		retn
		nop
rix_get_ins		endp

ad_init			proc	near				; 仅仅被set_new_int调用过。 
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4							; bp+4

		push	bp
		mov	bp,sp
		push	si
		mov	ax,388h							; 取声卡端口号388，送ax
		mov	ds:Adlib_port,ax				; 保存声卡端口号至临时地址
		call	ad_test						; 测试声卡兼容性
		mov	si,ax							; 返回值送si（1为成功，0为失败）
		call	go_on_prep
		mov	ax,si
		pop	si
		mov	sp,bp
		pop	bp
		retn
		nop	                   
ad_init		endp

go_on_prep		proc	near				; 注意仅仅被前面的函数调用过，是个一次性函数
;==========================================================================
;                              SUBROUTINE
;==========================================================================
		push	si						; 保存声卡测试结果
		call	mfill_7F
		call	data_trans
		sub	ax,ax						; 清空ax
		push	ax						; PARAMETER_1 = 0
		call	ser_reg_op
		add	sp,2
		sub	ax,ax
		push	ax						; PARAMETER_3
		push	ax						; PARAMETER_2
		push	ax						; PARAMETER_1
		call	mem_to_ad
		add	sp,6
		sub	si,si
loc_43:
		push	si
		call	ad_a0b0_reg
		add	sp,2
		inc	si
		cmp	si,9						; 如果si 不足9
		jl	loc_43						; 循环
		mov	ax,1
		push	ax						; PARAMETER_1
		call	only_one
		add	sp,2
		mov	ax,1
		push	ax
		call	wavef_ctrl
		add	sp,2
		pop	si
		retn
go_on_prep		endp

ser_reg_op		proc	near				; 被go_on_prep 和data_prepare调用。
;==========================================================================
;                     查看rix文件第三个字节处的信息
;==========================================================================

PARAMETER_1	=	4						; bp+4

		push	bp
		mov	bp,sp						; 准备堆栈
		push	si
		mov	si,[bp+PARAMETER_1]			; 该参数一般为0 值，大概是标识单声道、立体声。
		or	si,si						; 检测si
		jz	short stereo				; 看si是否为0
		mov	ax,6						; si不为0。
		push	ax						; 操作6 号寄存器
		call	ad_a0b0_reg				; 
		add	sp,2
		mov	ax,7
		push	ax
		call	ad_a0b0_reg
		add	sp,2
		mov	ax,8
		push	ax
		call	ad_a0b0_reg				; 上面三个操作将6、7、8号寄存器清零
		add	sp,2
		sub	ax,ax
		push	ax						; PARAMETER_3 = 0
		mov	cx,18h
		push	cx						; PARAMETER_2 = 18h
		mov	cx,8
		push	cx						; PARAMETER_1 = 8
		call	ad_a0b0l_reg
		add	sp,6
		sub	ax,ax
		push	ax						; PARAMETER_3 = 0
		mov	ax,1Fh
		push	ax						; PARAMETER_2 = 1Fh
		mov	ax,7
		push	ax						; PARAMETER_1 = 7
		call	ad_a0b0l_reg
		add	sp,6
		;-----------------------------------------------------------------------------
stereo:									; si 为0
		mov	ax,si						; si送ax
		mov	ds:[7C1h],al				; 低字节送ds:[7C1h]
		mov	byte ptr ds:[8B6h],0		; 清零ds:[8B6h]
		call	ins_to_arr
		call	ad_bd_reg
		pop	si
		mov	sp,bp
		pop	bp
		retn
ser_reg_op		endp

wavef_ctrl		proc	near				; 仅仅被go_on_prep调用过，启用波形控制
;==========================================================================
;                              启用波形控制
;==========================================================================
PARAMETER_1	=	4			; bp+4

		push	bp								
		mov	bp,sp								; 准备堆栈
		push	si								; PARAMETER_3
		cmp	word ptr [bp+PARAMETER_1],1
		cmc										; Complement carry
		sbb	ax,ax
		and	ax,20h
		mov	ds:[83Ch],ax						; 用参数处理[83Ch]处的数据
		sub	si,si
loc_45:
		sub	ax,ax
		push	ax								; PARAMETER_2
		mov	al,reg_data[si]
		sub	ah,ah
		add	ax,0E0h
		push	ax								; PARAMETER_1
		call	ad_bop
		add	sp,4
		inc	si
		cmp	si,12h
		jl	loc_45								; Jump if <
		push	word ptr ds:[83Ch]
		mov	ax,1								; 1号声卡寄存器？
		push	ax
		call	ad_bop
		add	sp,4
		pop	si
		mov	sp,bp
		pop	bp
		retn
wavef_ctrl		endp

only_one		proc	near				; 被调用两次
;==========================================================================
;                               无参函数
;==========================================================================		
		db	23	dup(90h)				; 真是混帐，其实这个函数是个无参函数。
par_one:
		mov	ax,1						
		mov	ds:[0C18h],ax				; 将ds:[0C18h]处填1。
		mov	cx,19h						; cx = 19h = 25
		mov	ax,cx
		xor	dx,dx						; 这里一个imul cx等价于mov 和xor
		mov	ds:[7DAh],ax				; 将ds:[7DAh]处的值设为19h
		retn
only_one		endp

mem_to_ad		proc	near				; 

PARAMETER_1	=	4			; bp+4
PARAMETER_2	=	6			; bp+6
PARAMETER_3	=	8			; bp+8

		push	bp
		mov	bp,sp
		mov	al,[bp+PARAMETER_1]
		mov	ds:[7C0h],al
		mov	al,[bp+PARAMETER_2]				; ad_bd_reg要使用。
		mov	ds:[89Eh],al
		mov	al,[bp+PARAMETER_3]
		mov	ds:[7D8h],al					; ad_8_reg要使用
		call	ad_bd_reg
		call	ad_8_reg
		mov	sp,bp
		pop	bp
		retn                       
mem_to_ad		endp

prepare_wave	proc	near				; 仅仅被rix_proc调用
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4			; bp+4
PARAMETER_2	=	6			; bp+6
LOCAL_2		=	-4			; bp+0FFFCh
LOCAL_1		=	-2			; bp+0FFFEh


		push	bp
		mov	bp,sp
		sub	sp,4
		push	di
		push	si
		mov	si,[bp+PARAMETER_2]
		mov	di,[si+34h]
		lea	bx,[si+34h]		; Load effective addr
		mov	ax,[bx+2]
		mov	[bp+LOCAL_2],ax
		lea	ax,[si+1Ah]		; Load effective addr
		mov	[bp+LOCAL_1],ax
		cmp	byte ptr ds:[7C1h],0
		je	short loc_49		; Jump if equal
		mov	dx,[bp+PARAMETER_1]
		cmp	dx,6
		jl	short loc_49		; Jump if <
		jnz	short loc_48		; Jump if not zero
		push	di			; PARAMETER_3
		push	si			; PARAMETER_2
		mov	al,ds:[176h]
		sub	ah,ah
		push	ax			; PARAMETER_1
		call	buffer_opr
		add	sp,6
		push	word ptr [bp+LOCAL_2]
		push	word ptr [bp+LOCAL_1]
		mov	al,ds:[177h]
		jmp	short loc_50
		nop	                        
loc_48:
		push	di
		push	si
		mov	bx,dx
		shl	bx,1			; Shift w/zeros fill
		mov	al,ds:[16Ah][bx]
		jmp	short loc_50
loc_49:
		push	di			; PARAMETER_3
		push	si			; PARAMETER_2
		mov	bx,[bp+PARAMETER_1]
		shl	bx,1			; Shift w/zeros fill
		mov	al,ds:[164h][bx]
		sub	ah,ah
		push	ax			; PARAMETER_1
		mov	si,bx
		call	buffer_opr
		add	sp,6
		push	word ptr [bp+LOCAL_2]	; PARAMETER_3
		push	word ptr [bp+LOCAL_1]	; PARAMETER_2

		mov	al,ds:[165h][si]
loc_50:
		sub	ah,ah
		push	ax			; PARAMETER_1
		call	buffer_opr
		add	sp,6
		pop	si
		pop	di
		mov	sp,bp
		pop	bp
		retn
		nop	                      
prepare_wave		endp

rix_B0_pro		proc	near				; 仅仅被rix_proc调用
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4			; bp+4
PARAMETER_2	=	6			; bp+6

		push	bp
		mov	bp,sp
		push	di
		push	si
		mov	bx,[bp+PARAMETER_1]
		cmp	byte ptr ds:[7C1h],0
		je	short loc_53		; Jump if equal
		cmp	bx,6
		jl	short loc_53		; Jump if <
		jnz	short loc_51		; Jump if not zero
		mov	si,1
		jmp	short loc_52
		nop
loc_51:
		sub	si,si
loc_52:
		mov	ax,bx
		shl	ax,1			; Shift w/zeros fill
		add	si,ax
		mov	di,ds:[16Ah][si]
		jmp	short loc_54
			                        ; now data because: after jmp/ret
loc_53:
		shl	bx,1			; Shift w/zeros fill
		mov	di,ds:[165h][bx]
loc_54:
		and	di,0FFh
		cmp	word ptr [bp+PARAMETER_2],7Fh
		ja	short loc_55		; Jump if above
		mov	cx,[bp+PARAMETER_2]
		jmp	short loc_56
		nop
loc_55:
		mov	cx,7Fh
loc_56:
		mov	ds:[0C28h][di],cl
		push	di			; PARAMETER_1
		call	ad_40_reg
		add	sp,2
		pop	si
		pop	di
		mov	sp,bp
		pop	bp
		retn
			                        ; now data because: after jmp/ret
rix_B0_pro		endp

rix_A0_pro		proc	near				; 仅仅被rix_proc调用，但是自己调用了一次傅立叶
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4			; bp+4 一个拍的高字节的0-3 位
PARAMETER_2	=	6			; bp+6 一个拍的低字节已经扩大64倍

		push	bp
		mov	bp,sp
		push	si
		mov	si,[bp+PARAMETER_1]

		cmp	byte ptr ds:[7C1h],0
		je	short _7C1h_zero								; Jump if equal
		cmp	si,6										; 看看一拍的高字节是A6 么？
		ja	short is_7_8								; Jump if above
_7C1h_zero:
		cmp	word ptr [bp+PARAMETER_2],3FFFh
		ja	short so_large								; Jump if above
		mov	dx,[bp+PARAMETER_2]
		jmp	short parm2_ok								; 主要判断参数2是否超过3FFF，如果超过，就以3FFF算
		nop
so_large:
		mov	dx,3FFFh
parm2_ok:
		push	dx										; PARAMETER_2
		push	si										; PARAMETER_1
		call	big_fourrier
		add	sp,4
		mov	al,ds:[0C1Ch][si]
		sub	ah,ah
		push	ax										; PARAMETER_3
		mov	al,ds:[8B8h][si]
		push	ax										; PARAMETER_2
		push	si										; PARAMETER_1
		call	ad_a0b0l_reg
		add	sp,6
is_7_8:
		pop	si
		mov	sp,bp
		pop	bp
		retn
		nop	                       
rix_A0_pro		endp

rix_C0_pro		proc	near				; 仅仅被rix_proc调用
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4			; bp+4
PARAMETER_2	=	6			; bp+6


		push	bp
		mov	bp,sp
		push	di

		push	si
		mov	si,[bp+PARAMETER_2]
		sub	si,0Ch
		jns	short loc_61		; Jump if not sign
		sub	si,si
loc_61:
		mov	di,[bp+PARAMETER_1]
		cmp	di,6
		jb	short loc_65		; Jump if below
		cmp	byte ptr ds:[7C1h],0
		je	short loc_65		; Jump if equal
		cmp	di,6
		jne	short loc_62		; Jump if not equal
		sub	ax,ax
		push	ax
		push	si



		mov	ax,di
		jmp	short loc_63
		nop
loc_62:
		cmp	di,8
		jne	short loc_64		; Jump if not equal
		sub	ax,ax
		push	ax			; PARAMETER_3



		push	si			; PARAMETER_2
		mov	cx,di
		push	cx			; PARAMETER_1
		call	ad_a0b0l_reg
		add	sp,6
		sub	ax,ax
		push	ax			; PARAMETER_3
		lea	ax,[si+7]		; Load effective addr
		push	ax			; PARAMETER_2
		mov	ax,7
loc_63:
		push	ax			; PARAMETER_1
		call	ad_a0b0l_reg
		add	sp,6
loc_64:
		mov	al,ds:[0E8h][di]
		or	ds:[8B6h],al
		call	ad_bd_reg
		pop	si
		pop	di
		mov	sp,bp
		pop	bp
		retn
			                        ; now data because: after jmp/ret
loc_65:
		mov	ax,1
		push	ax			; PARAMETER_3
		push	si			; PARAMETER_2
		push	di			; PARAMETER_1
		call	ad_a0b0l_reg
		add	sp,6
		pop	si
		pop	di
		mov	sp,bp
		pop	bp
		retn
			     
rix_C0_pro		endp

switch_ad_bd	proc	near


PARAMETER_1	=	4							; bp+4

		push	bp
		mov	bp,sp
		push	si							; 保存si，调用该函数时，可能si也是输入参数之一
		mov	si,[bp+PARAMETER_1]				; 参数送si
		cmp	byte ptr ds:[7C1h],0			; 看ds:[7C1h] 处的内容是否为0
		je	short loc_66					; 为0 则执行loc_66
		cmp	si,6							; 看参数值是否小于6
		jb	short loc_66					; 小于6 则执行loc_66
		mov	al,byte ptr ds:[0E8h][si]
		not	al
		and	ds:[8B6h],al
		call	ad_bd_reg
		pop	si
		mov	sp,bp
		pop	bp
		retn
		nop
loc_66:										; 参数1 小于6 或者ds:[7C1h] 处的内容为0
		sub	ax,ax							; 清零ax
		push	ax							; PARAMETER_3 = 0
		mov	al,ds:[8B8h][si]				; al 的值为ds:[8B8h]偏移参数值个地址的内容
		sub	ah,ah							; 清零ah
		push	ax							; PARAMETER_2
		push	si							; PARAMETER_1 = 参数做参数
		call	ad_a0b0l_reg
		add	sp,6							; 恢复堆栈
		pop	si
		mov	sp,bp
		pop	bp
		retn
			                       
switch_ad_bd		endp

ins_to_arr		proc	near				; 注意ins_maybe 处很可能是音乐数据，且为一次性函数
;==========================================================================
;                             将ins数据读入数组
;==========================================================================

		push	si							; 保存si
		sub	si,si							; si = 0
ins_loop:
		cmp	byte ptr ins_maybe[si],0		; 看ins_maybe+si 处的内容是否为0 （0<si<18）
		je	short flag_zero					; Jump if equal
		sub	ax,ax							; ins_maybe+si 处的内容为1,清零ax
		push	ax							; PARAMETER_3 = 0
		mov	ax,102h							; PARAMETER_2 = 102h
		jmp	short data_prepared
			                        
flag_zero:									; ins_maybe 处的内容为0
		sub	ax,ax							; 清零ax
		push	ax							; PARAMETER_3 = 0
		mov	ax,0F4h							; PARAMETER_2 = 0F4h
data_prepared:
		push	ax							; PARAMETER_2 
		push	si							; PARAMETER_1 = si
		call	array_pp
		add	sp,6							; 恢复堆栈
		inc	si								; si++
		cmp	si,12h							
		jl	ins_loop						; 当si不到18 时，循环
		;-------------------------------------------------------------------
		cmp	byte ptr ds:[7C1h],0
		je	short need_not_pro					; Jump if equal
		sub	ax,ax
		push	ax							; PARAMETER_3
		mov	cx,110h
		push	cx							; PARAMETER_2
		mov	cx,0Ch
		push	cx							; PARAMETER_1
		call	array_pp
		add	sp,6							; 恢复堆栈
		sub	ax,ax
		push	ax							; PARAMETER_3
		mov	cx,11Eh
		push	cx							; PARAMETER_2
		mov	cx,0Fh
		push	cx							; PARAMETER_1
		call	array_pp
		add	sp,6
		sub	ax,ax
		push	ax							; PARAMETER_3
		mov	cx,12Ch
		push	cx							; PARAMETER_2
		mov	cx,10h
		push	cx							; PARAMETER_1
		call	array_pp
		add	sp,6
		sub	ax,ax
		push	ax							; PARAMETER_3
		mov	cx,13Ah
		push	cx							; PARAMETER_2
		mov	cx,0Eh
		push	cx							; PARAMETER_1
		call	array_pp
		add	sp,6
		sub	ax,ax
		push	ax							; PARAMETER_3
		mov	cx,148h
		push	cx							; PARAMETER_2
		mov	cx,11h
		push	cx							; PARAMETER_1
		call	array_pp
		add	sp,6
		sub	ax,ax
		push	ax							; PARAMETER_3
		mov	ax,156h
		push	ax							; PARAMETER_2
		mov	ax,0Dh
		push	ax							; PARAMETER_1
		call	array_pp
		add	sp,6
need_not_pro:
		pop	si
		retn
		nop	                      
ins_to_arr		endp

mfill_7F		proc	near				; 一次性函数
;==========================================================================
;                             填充数据
;==========================================================================
		sub	bx,bx								; 初始化bx为0
_loop:

		mov	byte ptr ds:[0C28h][bx],7Fh			; 将7Fh（127）填入ds:[0C28h]为首址，偏移bx的地方
		inc	bx
		cmp	bx,12h								; 看bx 是否达到18
		jl	_loop								; 循环
		retn
mfill_7F		endp

strm_and_fr		proc	near				; 一次性函数，仅仅被sub_32调用
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4			; bp+4
PARAMETER_2	=	6			; bp+6
LOCAL_2		=	-4			; bp+0FFFCh
LOCAL_1		=	-2			; bp+0FFFEh

		push	bp
		mov	bp,sp
		sub	sp,4
		push	di
		push	si
		mov	si,[bp+PARAMETER_2]
		mov	ax,0B503h
		mov	dx,1
		push	dx
		push	ax
		mov	ax,4000h
		mov	dx,2
		push	dx
		push	ax
		mov	ax,19h
		cwd				; Word to double word
		push	dx
		push	ax
		mov	cx,64h
		mov	ax,si
		imul	cx			; dx:ax = reg * ax
		cwd				; Word to double word
		push	dx
		push	ax
		mov	di,ax
		mov	[bp+LOCAL_2],di
		mov	[bp+LOCAL_1],dx
		call	bit_mult
		push	dx
		push	ax
		mov	ax,0CB78h
		sub	dx,dx
		push	dx
		push	ax
		mov	ax,[bp+PARAMETER_1]
		mov	cx,ax
		shl	ax,1			; Shift w/zeros fill
		add	ax,cx
		shl	ax,1			; Shift w/zeros fill
		cwd				; Word to double word
		add	ax,[bp+LOCAL_2]
		adc	dx,[bp+LOCAL_1]
		push	dx
		push	ax
		call	bit_mult
		push	dx
		push	ax
		call	fourier_maybe
		push	dx
		push	ax
		call	bit_mult
		push	dx
		push	ax
		call	fourier_maybe
		pop	si
		pop	di
		mov	sp,bp
		pop	bp
		retn
		nop	                      
strm_and_fr		endp

sub_32			proc	near				; 一次性函数，仅仅被data_trans调用
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4								; bp+4
PARAMETER_2	=	6								; bp+6
PARAMETER_3	=	8								; bp+8
LOCAL_2		=	-4								; bp+0FFFCh
LOCAL_1		=	-2								; bp+0FFFEh

		push	bp
		mov	bp,sp
		sub	sp,4
		push	di
		push	si
		mov	si,[bp+PARAMETER_1]
		push	64h								; PARAMETER_2 恒为64h
		push	word ptr [bp+PARAMETER_2]		; PARAMETER_1
		call	strm_and_fr
		add	sp,4
		mov	[bp+LOCAL_2],ax
		mov	[bp+LOCAL_1],dx
		add	ax,4
		mov	cl,3
		shr	ax,cl								; Shift w/zeros fill
		mov	[si],ax
		inc	si
		inc	si
		mov	di,0Bh
loc_72:
		mov	ax,6Ah
		cwd										; Word to double word
		push	dx								; PARAMETER_3
		push	ax								; PARAMETER_2
		lea	ax,[bp+LOCAL_2]						; Load effective addr
		push	ax								; PARAMETER_1
		call	new_ss_par
		mov	ax,64h
		cwd										; Word to double word
		push	dx								; PARAMETER_3
		push	ax								; PARAMETER_2
		lea	ax,[bp+LOCAL_2]						; Load effective addr
		push	ax								; PARAMETER_1
		call	call_fourier
		add	ax,4
		mov	cl,3
		shr	ax,cl								; Shift w/zeros fill
		mov	[si],ax
		inc	si
		inc	si
		dec	di
		jnz	loc_72								; Jump if not zero
		pop	si
		pop	di
		mov	sp,bp
		pop	bp
		retn
		nop	  
		nop                    
sub_32		endp

data_trans		proc	near				; 一次性函数，仅仅被go_on_prep调用
;==========================================================================
;                              SUBROUTINE
;==========================================================================
		push	di
		push	si
		sub	di,di
		mov	si,9C0h
loc_73:
		mov	ax,64h
		push	ax						; PARAMETER_3
		push	di						; PARAMETER_2
		push	si						; PARAMETER_1
		call	sub_32
		add	sp,6						; 丢弃上一次的参数
		add	di,4						; 参数2 加4
		add	si,18h						; 参数1 加18h
		cmp	si,[0C18h]					; 看参数1 的值是否达到ds:[0C18h]处的大小，这里极有可能是rix文件自己的值
		jb	loc_73						; 没有则循环
		mov	di,[7C2h]					; 地址[7C2h]里的内容送di
		mov	bx,[8A0h]					; [8A0h]处的内容送bx
loc_74:
		mov	word ptr [bx],9C0h			; bx代表的地址
		inc	bx							; 
		inc	bx							; bx加2
		mov	word ptr [di],0				; di代表的地址
		inc	di
		inc	di							; di加2
		cmp	bx,8B6h						; 看bx是否达到2230
		jb	loc_74						; 没有则循环
		sub	cx,cx						; cx = 0
		mov	si,cx						; si = 0
loc_75:
		sub	dx,dx						; dx = 0
loc_76:
		mov	ds:[83Eh][si],cl
		mov	ds:[7DCh][si],dl
		inc	si
		inc	dx
		cmp	dx,0Ch						; 12
		jb	loc_76						; 不到12 就循环
		inc	cx
		cmp	cx,8						
		jb	loc_75						; 不到8 就循环
		pop	si
		pop	di
		retn
		nop	                     
data_trans		endp

big_fourrier	proc	near				; 一次性函数，仅仅被rix_A0_pro调用
;==========================================================================
;                     复杂运算后，调用一次“傅立叶”
;==========================================================================
PARAMETER_1	=	4			; bp+4				; 一个拍的高字节的0-3 位
PARAMETER_2	=	6			; bp+6				; 一个拍的低字节扩大64 倍
LOCAL_3		=	-6			; bp+0FFFAh
LOCAL_2		=	-4			; bp+0FFFCh
LOCAL_1		=	-2			; bp+0FFFEh

		push	bp
		mov	bp,sp
		sub	sp,6								; 准备堆栈参数，局部变量
		push	di
		push	si								; 预备工作
		mov	ax,[bp+PARAMETER_2]					; 最大是3FFF
		sub	ax,2000h							; 暴减2000h！可能为负数的。
		imul	word ptr ds:[7DAh]				; 代符号乘法，dx:ax = data * ax，这里其实是常数19h
		mov	[bp+LOCAL_3],ax
		mov	[bp+LOCAL_2],dx						; 暂存结果
		cmp	ax,0FFh								; 好像是和FF 比
		jne	short not_00FF						; Jump if not equal
		cmp	dx,0								; 好像是和0 比
		jne	short not_00FF						; Jump if not equal
		mov	bx,[bp+PARAMETER_1]
		mov	ax,ds:[0C3Ah]						; 曾被mfill函数填为7F
		shl	bx,1								; Shift w/zeros fill
		mov	ds:[8A0h][bx],ax
		mov	ax,ds:[0C3Ch]
		mov	ds:[7C2h][bx],ax
		pop	si
		pop	di
		mov	sp,bp
		pop	bp
		retn
not_00FF:										; 多半会执行倒这里
		push	0								; PARAMETER_4
		push	2000h								; PARAMETER_3
		push	word ptr [bp+LOCAL_2]			; PARAMETER_2
		push	word ptr [bp+LOCAL_3]			; PARAMETER_1
		call	fourier_maybe
		mov	di,ax
		or	di,di								; Zero ?
		jge	short loc_78						; Jump if > or =
		mov	ax,18h
		sub	ax,di
		mov	cx,0FFE7h
		mov	bx,ax
		cwd										; Word to double word
		idiv	cx								; ax,dx rem=dx:ax/reg
		mov	si,[bp+PARAMETER_1]
		shl	si,1								; Shift w/zeros fill
		mov	ds:[7C2h][si],ax
		mov	ds:[0C3Ch],ax
		mov	ax,bx
		sub	ax,18h
		mov	cx,19h
		cwd										; Word to double word
		idiv	cx								; ax,dx rem=dx:ax/reg
		mov	bx,dx
		or	bx,bx								; Zero ?
		jz	short loc_79						; Jump if zero
		mov	ax,cx
		sub	ax,bx
		mov	bx,ax
		jmp	short loc_79
		nop	                        
loc_78:
		mov	[bp+LOCAL_1],di
		mov	cx,19h
		cwd										; Word to double word
		idiv	cx								; ax,dx rem=dx:ax/reg
		mov	bx,[bp+PARAMETER_1]
		shl	bx,1								; Shift w/zeros fill
		mov	ds:[7C2h][bx],ax
		mov	ds:[0C3Ch],ax
		mov	ax,[bp+LOCAL_1]
		cwd										; Word to double word
		idiv	cx								; ax,dx rem=dx:ax/reg
		mov	bx,dx
loc_79:
		mov	ax,bx
		mov	cx,18h
		imul	cx								; dx:ax = reg * ax
		add	ax,9C0h
		mov	bx,[bp+PARAMETER_1]
		shl	bx,1								; Shift w/zeros fill
		mov	ds:[8A0h][bx],ax
		mov	ds:[0C3Ah],ax
		mov	ax,[bp+LOCAL_3]
		mov	dx,[bp+LOCAL_2]
		mov	ds:[1B6h],ax
		mov	ds:[1B8h],dx
		pop	si
		pop	di
		mov	sp,bp
		pop	bp
		retn
		db 52 dup(0)				; 垃圾数据填充定位
big_fourrier		endp

buffer_opr		proc	near
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4			; bp+4			
PARAMETER_2	=	6			; bp+6
PARAMETER_3	=	8			; bp+8			


		push	bp
		mov	bp,sp							; 准备堆栈传递参数
		push	di
		mov	di,[bp+PARAMETER_1]
		mov	ax,di
		shl	di,1							; Shift w/zeros fill
		add	di,ax
		shl	di,1							; Shift w/zeros fill
		add	di,ax
		shl	di,1							; Shift w/zeros fill
		add	di,[8C4h]
		mov	cx,0Dh
		mov	bx,[bp+PARAMETER_2]

locloop_80:									; 将array_pp准备的数组内容存取
		inc	bx
		inc	bx
		mov	al,[bx-2]						; 每隔一个字节取数据
		mov	[di],al
		inc	di								; 顺序存入di所指
		loop	locloop_80					; Loop if cx > 0

		mov	al,[bp+PARAMETER_3]
		and	al,3
		mov	[di],al
		push	word ptr [bp+PARAMETER_1]	; PARAMETER_1
		call	wave_gen
		add	sp,2							; 还原堆栈
		pop	di
		mov	sp,bp
		pop	bp
		retn
buffer_opr		endp

array_pp		proc	near				; 重要函数！有三个输入参数
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4						; bp+4  ins 区的偏移量
PARAMETER_2	=	6						; bp+6
PARAMETER_3	=	8						; bp+8  通常为0

		push	bp
		mov	bp,sp							; 准备堆栈传递参数
		sub	sp,1Ch							; 在堆栈里面预留一块空间
		push	di							; 保存di
		mov	di,[bp+PARAMETER_2]				; 参数2 送di
		mov	bx,03CCh						; 真的是个常量！
fill_local:
		mov	al,[di]							; ds:di处的内容送al，也就是内置的乐器块
		inc	di								; 
		sub	ah,ah							; 清空ah
		mov	[bx],ax							; 向从03CCh处开始的一段内存里写入乐器信息。
		inc	bx
		inc	bx								; 下一个信息
		mov	ax,03E6h						; 结束的上限
		cmp	bx,ax							; 看看所有的内存区都填满没。
		jb	fill_local						; 循环
		push	word ptr [bp+PARAMETER_3]	; PARAMETER_3
		mov	ax,03CCh						; 故弄玄虚，其实是个常量
		push	ax							; PARAMETER_2
		push	word ptr [bp+PARAMETER_1]	; PARAMETER_1
		call	buffer_opr
		add	sp,6							; 恢复堆栈
		pop	di
		mov	sp,bp
		pop	bp
		retn	
		db	7Ch		dup(0)					; 垃圾数据填充定位              
array_pp		endp

wave_gen		proc	near
;==========================================================================
;                         	波形生成函数
;==========================================================================
PARAMETER_1	=	4							; bp+4

		push	bp
		mov	bp,sp
		push	si
		mov	si,[bp+PARAMETER_1]
		call	ad_bd_reg
		call	ad_8_reg
		push	si							; PARAMETER_1
		call	ad_40_reg
		add	sp,2
		push	si							; PARAMETER_1
		call	ad_c0_reg
		add	sp,2
		push	si							; PARAMETER_1
		call	ad_60_reg
		add	sp,2
		push	si							; PARAMETER_1
		call	ad_80_reg	
		add	sp,2
		push	si							; PARAMETER_1
		call	ad_20_reg
		add	sp,2
		push	si							; PARAMETER_1
		call	ad_e0_reg
		add	sp,2
		pop	si
		mov	sp,bp
		pop	bp
		retn			                  
wave_gen		endp

ad_40_reg		proc	near
;==========================================================================
;                              声卡40 寄存器组操作
;==========================================================================
PARAMETER_1	=	4						; bp+4

		push	bp
		mov	bp,sp						; 准备堆栈传递参数
		push	si						; 保存si
		mov	si,[bp+PARAMETER_1]			; 参数1 送si
		mov	cl,ds:[0C28h][si]			; 将ds:[0C28h]开始，偏移si处的数据送cl
		sub	ch,ch						; 清零ch
		mov	ax,3Fh						; 3Fh（63）送ax
		mov	bx,si						; si送bx
		mov	dx,si						; si送dx
		shl	si,1						; si'=si*2
		add	si,dx						; si'=si*2+si
		shl	si,1						; si'=(si+si*2)*2
		add	si,dx						; si'=(si+si*2)*2+si
		shl	si,1						; si'=((si+si*2)*2+si)*2
		mov	dl,ds:[8CCh][si]			; 将ds:[8CCh]偏移si处的数据（字节）送dl，dh 的内容还为si的高字节
		and	dx,ax						; dx 加上3Fh
		sub	ax,dx						; 再加上3Fh，保存于ax
		mul	cx							; cx 为ds:[0C28h]处的数据（低字节），结果保存在dx:ax
		shl	ax,1						; ax乘以2
		add	ax,7Fh						; ax+7Fh
		mov	cx,0FEh
		sub	dx,dx
		div	cx							; ax,dx rem=dx:ax/reg
		sub	ax,3Fh
		neg	ax
		mov	cl,6
		mov	dl,ds:[8C4h][si]
		sub	dh,dh
		shl	dx,cl						; Shift w/zeros fill
		or	ax,dx
		push	ax						; 送所选声卡寄存器的数据
		mov	al,ds:[180h][bx]
		sub	ah,ah
		add	ax,40h						; 声卡40 寄存器组操作
		push	ax						; 送端口388 的参数，选择声卡寄存器号
		call	ad_bop
		add	sp,4
		pop	si
		mov	sp,bp
		pop	bp
		retn
		nop	                       
ad_40_reg		endp

ad_8_reg		proc	near
;==========================================================================
;                          Adlib声卡8号寄存器操作
;==========================================================================
		cmp	byte ptr ds:[7D8h],1		; 查看ds:[7D8h]处的字节是否为1
		cmc								; 翻转CF
		sbb	ax,ax						; 清零ax 并减去CF
		and	ax,40h						; 只保留第六位
		push	ax						; 作为送所选声卡寄存器的数据
		mov	ax,8						; ax = 8
		push	ax						; 选择8 号声卡寄存器
		call	ad_bop
		add	sp,4						; 恢复堆栈
		retn
		nop	                     
ad_8_reg		endp

ad_c0_reg		proc	near
;==========================================================================
;                       极有可能是INS文件操作
;==========================================================================
PARAMETER_1	=	4			; bp+4

		push	bp
		mov	bp,sp
		push	si							; 保存si
		mov	si,[bp+PARAMETER_1]				; 取参数1送si
		cmp	byte ptr ins_maybe[si],1		; 查看ins数据区的值是否为1
		je	short not_zero					; 如果是1
		mov	bx,si							; 如果是0，si（位置）送bx
		shl	bx,1							; bx*2
		add	bx,si							; bx*2+bx
		shl	bx,1							; (bx*2+bx)*2
		add	bx,si							; ((bx*2+bx)*2)+bx
		shl	bx,1							; (((bx*2+bx)*2)+bx)*2，最终结果保存在bx
		cmp	byte ptr ds:[8D0h][bx],1		; 上面一步得到了新的偏移值，比较ds:[8D0h]偏移bx处的值是否为1
		sbb	ax,ax							; 将0-CF的值保存在ax
		neg	ax								; 求ax 的补码
		mov	cl,ds:[8C6h][bx]
		sub	ch,ch
		shl	cx,1							; cx*2
		or	ax,cx
		push	ax							; 送所选声卡寄存器的数据
		mov	al,ad_data_c0[si]
		sub	ah,ah
		add	ax,0C0h							; 选择声卡的C0号开始的寄存器
		push	ax
		call	ad_bop
		add	sp,4
not_zero:
		pop	si								; 还原si
		mov	sp,bp							; 什么也没有做
		pop	bp
		retn
		nop
ad_c0_reg		endp

ad_60_reg		proc	near
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4							; bp+4

		push	bp
		mov	bp,sp							; 准备对堆栈传递参数
		push	si
		mov	si,[bp+PARAMETER_1]
		mov	cx,si
		mov	ax,si
		shl	si,1							; Shift w/zeros fill
		add	si,ax
		shl	si,1							; Shift w/zeros fill
		add	si,ax
		shl	si,1							; Shift w/zeros fill
		mov	al,ds:[8CAh][si]
		and	ax,0Fh
		mov	dx,cx
		mov	cl,4
		mov	bl,ds:[8C7h][si]
		sub	bh,bh
		shl	bx,cl							; Shift w/zeros fill
		or	ax,bx
		push	ax							; 送60 寄存器的数据
		mov	bx,dx
		mov	al,reg_data[bx]
		sub	ah,ah
		add	ax,60h							; 向声卡的60开始的寄存器操作
		push	ax
		call	ad_bop
		add	sp,4
		pop	si
		mov	sp,bp
		pop	bp
		retn
			                       
ad_60_reg		endp

ad_80_reg		proc	near
;==========================================================================
;                            声卡80寄存器组操作
;==========================================================================
PARAMETER_1	=	4			; bp+4

		push	bp
		mov	bp,sp
		push	si
		mov	si,[bp+PARAMETER_1]
		mov	cx,si
		mov	ax,si
		shl	si,1			; Shift w/zeros fill
		add	si,ax
		shl	si,1			; Shift w/zeros fill
		add	si,ax
		shl	si,1			; Shift w/zeros fill
		mov	al,ds:[8CBh][si]
		and	ax,0Fh
		mov	dx,cx
		mov	cl,4
		mov	bl,ds:[8C8h][si]
		sub	bh,bh
		shl	bx,cl			; Shift w/zeros fill
		or	ax,bx
		push	ax
		mov	bx,dx
		mov	al,reg_data[bx]
		sub	ah,ah
		add	ax,80h
		push	ax
		call	ad_bop
		add	sp,4
		pop	si
		mov	sp,bp
		pop	bp
		retn
ad_80_reg		endp

ad_20_reg		proc	near
;==========================================================================
;                          声卡20 寄存器组操作
;==========================================================================
PARAMETER_1	=	4								; bp+4

		push	bp
		mov	bp,sp
		push	si
		mov	si,[bp+PARAMETER_1]
		mov	bx,si
		shl	bx,1								; Shift w/zeros fill
		add	bx,si
		shl	bx,1								; Shift w/zeros fill
		add	bx,si
		shl	bx,1								; Shift w/zeros fill
		cmp	byte ptr ds:[8CDh][bx],1
		cmc										; Complement carry
		sbb	ax,ax
		and	ax,80h
		cmp	byte ptr ds:[8CEh][bx],1
		cmc										; Complement carry
		sbb	cx,cx
		and	cx,40h
		add	cx,ax
		cmp	byte ptr ds:[8C9h][bx],1
		cmc										; Complement carry
		sbb	ax,ax
		and	ax,20h
		add	ax,cx
		cmp	byte ptr ds:[8CFh][bx],1
		cmc										; Complement carry
		sbb	cx,cx
		and	cx,10h
		add	cx,ax
		mov	al,ds:[8C5h][bx]
		and	ax,0Fh
		add	cx,ax
		push	cx
		mov	al,reg_data[si]
		sub	ah,ah
		add	ax,20h
		push	ax
		call	ad_bop
		add	sp,4
		pop	si
		mov	sp,bp
		pop	bp
		retn
			                  
ad_20_reg		endp

ad_bd_reg		proc	near
;==========================================================================
;                       	声卡BD 寄存器操作
;==========================================================================
		cmp	byte ptr ds:[7C0h],1
		cmc							; Complement carry
		sbb	ax,ax
		and	ax,80h
		cmp	byte ptr ds:[89Eh],1
		cmc							; Complement carry
		sbb	cx,cx
		and	cx,40h
		or	ax,cx
		cmp	byte ptr ds:[7C1h],1
		cmc							; Complement carry
		sbb	cx,cx
		and	cx,20h
		or	ax,cx
		mov	cl,ds:[8B6h]
		sub	ch,ch
		or	ax,cx
		push	ax
		mov	ax,0BDh
		push	ax
		call	ad_bop
		add	sp,4
		retn
		nop
ad_bd_reg		endp

ad_e0_reg		proc	near
;==========================================================================
;                           声卡E0 寄存器组操作
;==========================================================================
PARAMETER_1	=	4			; bp+4

		push	bp
		mov	bp,sp
		push	di
		push	si
		mov	di,[bp+PARAMETER_1]
		cmp	word ptr ds:[83Ch],0
		je	short loc_93		; Jump if equal
		mov	bx,di
		shl	bx,1			; Shift w/zeros fill
		add	bx,di
		shl	bx,1			; Shift w/zeros fill
		add	bx,di
		shl	bx,1			; Shift w/zeros fill
		mov	al,ds:[8D1h][bx]
		and	ax,3
		mov	si,ax
		jmp	short loc_94
loc_93:
		sub	si,si
loc_94:
		push	si
		mov	al,reg_data[di]
		sub	ah,ah
		add	ax,0E0h
		push	ax
		call	ad_bop
		add	sp,4
		pop	si
		pop	di
		mov	sp,bp
		pop	bp
		retn
		nop
ad_e0_reg		endp

ad_a0b0l_reg	proc	near				;
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4			; bp+4
PARAMETER_2	=	6			; bp+6
PARAMETER_3	=	8			; bp+8
LOCAL_1		=	-2			; bp+0FFFEh


		push	bp
		mov	bp,sp							; 准备参数
		sub	sp,2							; 腾出一个字的空位子，后面将会用到。
		push	di
		push	si
		mov	di,[bp+PARAMETER_1]				; 用来选择具体的寄存器
		mov	si,[bp+PARAMETER_2]
		mov	al,[bp+PARAMETER_3]				; 参数3 的低字节送al，事实上每次传值时，都只给低字节部分赋值
		mov	ds:[0C1Ch][di],al				; 参数3 的低字节保存在ds:[0C1Ch] 偏移参数di个字节处	
		mov	ax,si							; 参数2 送ax
		mov	ds:[8B8h][di],al				; 参数2 的低字节保存在ds:[8B8h] 偏移参数di个字节处
		mov	bx,di							; 参数1 送bx
		shl	bx,1							; 参数1 扩大2 倍
		add	si,ds:[7C2h][bx]				; si（参数2）的值加上ds:[7C2h] 偏移2 倍参数1 个字节处
		cmp	si,5Fh							; 比较得到的si（新参数2）于十进制95 的大小
		jle	short loc_95					; 不超过95 的话，到loc_95 执行
		mov	si,offset data_75				; ('Tong using assembly 1994') 这里虽然是字符串，但是离乐器块也不远
loc_95:
		or	si,si							; 检测si（新参数2）的值
		jge	short loc_96					; 为非负值的话，到loc_96 处执行
		sub	si,si							; 否则清零后再执行loc_96
loc_96:
		mov	bx,di							; 参数1 送bx
		shl	bx,1							; 参数1 扩大2 倍
		mov	ax,ds:[8A0h][bx]				; ds:[8A0h] 偏移2 倍参数1 处的数值送ax
		mov	bl,ds:[7DCh][si]				; ds:[7DCh] 偏移新参数2 处的值之低字节送bl
		sub	bh,bh							; 清零bh
		shl	bx,1							; 得到的值扩大2 倍
		add	bx,ax							; 将前面的两个获取值相加
		mov	ax,[bx]							; 得到的结果作为地址，该地址内容送ax
		mov	[bp+LOCAL_1],ax					; 将ax的内容送到先前准备的空位子里面。
		push	ax							; 保存之。（可能为声卡功能数值）
		lea	ax,cs:[0A0h][di]				; 
		push	ax							; 保存之（可能为声卡寄存器号）
		call	ad_bop						; 声卡基本操作函数
		add	sp,4							; 恢复堆栈
		mov	al,ds:[83Eh][si]
		sub	ah,ah
		shl	ax,1							; Shift w/zeros fill
		shl	ax,1							; Shift w/zeros fill
		cmp	word ptr [bp+PARAMETER_3],1
		cmc									; Complement carry
		sbb	cx,cx
		and	cx,20h
		add	ax,cx
		mov	cl,[bp-1]
		and	cx,3
		add	ax,cx
		push	ax
		lea	ax,cs:[0B0h][di]				; 
		push	ax
		call	ad_bop
		add	sp,4
		pop	si
		pop	di
		mov	sp,bp
		pop	bp
		retn
ad_a0b0l_reg		endp

ad_a0b0_reg		proc	near
;==========================================================================
;                        操作声卡的A0和B0寄存器组
;==========================================================================
PARAMETER_1	=	4							; bp+4

		push	bp							
		mov	bp,sp							; 准备堆栈传递参数
		push	si							; 保存si
		mov	si,[bp+PARAMETER_1]				; 参数1 送si
		push	0							; 声卡调用的PARAMETER_2，送所选寄存器的数据（0） 
		lea	cx,cs:[0A0h][si]				; 声卡A0 寄存器组
		push	cx							; PARAMETER_1
		call	ad_bop
		add	sp,4							; 恢复堆栈
		push	0
		lea	ax,cs:[0B0h][si]				; 声卡B0 寄存器组
		push	ax
		call	ad_bop
		add	sp,4
		pop	si
		mov	sp,bp
		pop	bp
		retn
ad_a0b0_reg		endp

ad_test			proc	near
;==========================================================================
;                            Adlib 声卡测试函数
;==========================================================================

		push	di							; PARAMETER_4
		push	si							; PARAMETER_3
		mov	ax,60h
		push	ax							; PARAMETER_2
		mov	ax,4
		push	ax							; PARAMETER_1
		call	ad_bop
		add	sp,4
		mov	ax,80h
		push	ax
		mov	ax,4
		push	ax
		call	ad_bop
		add	sp,4
		mov	dx,ds:Adlib_port
		in	al,dx							; port 0, DMA-1 bas&add ch 0
		sub	ah,ah
		mov	di,ax
		mov	ax,0FFh
		push	ax
		mov	ax,2
		push	ax
		call	ad_bop
		add	sp,4
		mov	ax,21h
		push	ax
		mov	ax,4
		push	ax
		call	ad_bop
		add	sp,4
		mov	si,0C8h
loc_97:
		mov	dx,ds:Adlib_port
		in	al,dx							; port 0, DMA-1 bas&add ch 0
		dec	si
		jnz	loc_97							; Jump if not zero
		in	al,dx							; port 0, DMA-1 bas&add ch 0
		sub	ah,ah
		mov	si,ax
		mov	ax,60h
		push	ax
		mov	ax,4
		push	ax
		call	ad_bop
		add	sp,4
		mov	ax,80h
		push	ax
		mov	ax,4
		push	ax
		call	ad_bop
		add	sp,4
		mov	ax,di
		test	al,0E0h
		jnz	short loc_98					; Jump if not zero
		mov	ax,si
		and	al,0E0h
		cmp	al,0C0h
		jne	short loc_98					; Jump if not equal
		mov	ax,1
		pop	si
		pop	di
		retn
			                        		
loc_98:
		sub	ax,ax
		pop	si
		pop	di
		retn
			                        
ad_test		endp

ad_bop			proc	near				; 声卡的基本操作函数
;==========================================================================
;                            声卡的基本操作函数
;==========================================================================

PARAMETER_1	=	4					; bp+4
PARAMETER_2	=	6					; bp+6
		
		push	bp
		mov	bp,sp
		mov	ax,[bp+PARAMETER_1]
		mov	dx,ds:[0C1Ah]
		out	dx,al					; dx 现在为声卡的端口号388h
		in	al,dx			
		in	al,dx			
		in	al,dx			
		in	al,dx			
		in	al,dx			
		in	al,dx			
		mov	ax,[bp+PARAMETER_2]
		inc	dx
		out	dx,al					; port 1, DMA-1 bas&cnt ch 0
		dec	dx
			                        ; now data because: string or bytes
		db	38 dup (0ECh)			; 声卡延时
		pop bp
		retn
		db	56	dup (00h)			; 用来填充定位的垃圾数据
ad_bop		endp
		
bit_mult		proc	near				; 函数接受4个参数的怪乘函数
;==========================================================================
;                              怪异的乘法运算
;==========================================================================
PARAMETER_1	=	4			; bp+4
PARAMETER_2	=	6			; bp+6
PARAMETER_3	=	8			; bp+8
PARAMETER_4 =  10			; bp+0Ah

		push	bp
		mov	bp,sp							; 准备堆栈传递参数
		mov	ax,[bp+PARAMETER_2]				; 参数2 送ax
		mov	cx,[bp+PARAMETER_4]				; 参数4 送cx
		or	cx,ax
		mov	cx,[bp+PARAMETER_3]				; 参数3 送cx
		jnz	short loc_99					; 如果参数2、4 不是都为0 的话，转到loc_99 执行
		mov	ax,[bp+PARAMETER_1]				; 参数1 送ax
		mul	cx								; dx:ax = cx * ax，cx的值为参数3，ax的值为参数1
		pop	bp								; 
		retn	8							; 恢复堆栈，dx:ax里面保存了参数3 和参数1 的乘积
			                        
loc_99:										; 参数2、4 不是都为0，此时，cx为参数3，ax为参数2
		push	bx							; 保存bx	
		mul	cx								; dx:ax = reg * ax，cx的值为参数3，ax的值为参数2
		mov	bx,ax							; 乘积结果低字送bx，高字在dx
		mov	ax,[bp+PARAMETER_1]				; 参数1 送ax
		mul	word ptr [bp+PARAMETER_4]		; 参数1、4 相乘
		add	bx,ax							; 相乘结果的低字与前面结果的低字相加，结果保存与bx
		mov	ax,[bp+PARAMETER_1]				; 参数1 送ax
		mul	cx								; dx:ax = reg * ax，cx的值为参数3，ax为参数1
		add	dx,bx							; 将前面一步得到的值与相乘结果的高字相加
		pop	bx
		pop	bp
		retn	8
bit_mult		endp

fourier_maybe	proc	near				; 
;==========================================================================
;                              傅立叶变换？
;==========================================================================

PARAMETER_1	=	4						; bp+4
PARAMETER_2	=	6						; bp+6
PARAMETER_3	=	8						; bp+8
PARAMETER_4	=	10						; bp+0Ah

		push	bp
		mov	bp,sp						; 准备参数传递
		push	di						; 保存di
		push	si						; 保存si
		push	bx						; 保存bx
		xor	di,di						; di = 0
		mov	ax,[bp+PARAMETER_2]			; 参数2 传给ax
		cmp	ax,0
		jge	short p2_not_neg			; 如果ax为非负数
		inc	di							; 参数2 为负数
		mov	dx,[bp+PARAMETER_1]			; 将参数1 传递给dx
		neg	ax							; 求参数2 的补
		neg	dx							; 求参数1 的补
		sub	ax,1						; 
		mov	[bp+PARAMETER_2],ax		 	; 更新参数2
		mov	[bp+PARAMETER_1],dx			; 更新参数1
p2_not_neg:								; 如果参数2 为非负数，直接从这里开始
		mov	ax,[bp+PARAMETER_4]			; 将参数4 保存在ax
		cmp	ax,0						; 判断参数4 是否为非负数
		jge	short p4_not_neg			; 如果参数4 为非负数
		inc	di							; di 似乎是某种计数器
		mov	dx,[bp+PARAMETER_3]
		neg	ax
		neg	dx
		sub	ax,1
		mov	[bp+PARAMETER_4],ax
		mov	[bp+PARAMETER_3],dx
p4_not_neg:								; 如果参数4 为非负数，从这里开始，此时，所有的参数都经过了处理
		cmp	ax,0						; 
		jnz	short p4_ab_zero			; 如果ax不为0，这里实际上等价于“如果ax大于0”
		mov	cx,[bp+PARAMETER_3]			; cx 为参数3了。
		mov	ax,[bp+PARAMETER_2]
		xor	dx,dx						; dx = 0
		div	cx							; ax,dx rem=dx:ax/reg
		mov	bx,ax						; 商送bx，余数参与下一轮运算
		mov	ax,[bp+PARAMETER_1]
		div	cx							; ax,dx rem=dx:ax/reg
		mov	dx,bx
		jmp	short loc_106
p4_ab_zero:
		mov	bx,ax						; 参数4 送bx
		mov	cx,[bp+PARAMETER_3]			; 
		mov	dx,[bp+PARAMETER_2]
		mov	ax,[bp+PARAMETER_1]
loc_103:
		shr	bx,1						; P4 >> 1
		rcr	cx,1						; Rotate thru carry
		shr	dx,1						; Shift w/zeros fill
		rcr	ax,1						; Rotate thru carry
		cmp	bx,0						; 
		jnz	loc_103						; Jump if not zero
		div	cx							; ax,dx rem=dx:ax/reg
		mov	si,ax
		mul	word ptr [bp+PARAMETER_4]	; dx:ax = data * ax
		xchg	cx,ax
		mov	ax,[bp+PARAMETER_3]
		mul	si							; dx:ax = reg * ax
		add	dx,cx
		jc	short loc_104				; Jump if carry Set
		cmp	dx,[bp+PARAMETER_2]
		ja	short loc_104				; Jump if above
		jc	short loc_105				; Jump if carry Set

		cmp	ax,[bp+PARAMETER_1]
		jbe	short loc_105				; Jump if below or =
loc_104:
		dec	si
loc_105:
		xor	dx,dx						; Zero register
		xchg	si,ax
loc_106:
		dec	di
		jnz	short loc_107				; Jump if not zero
		neg	dx
		neg	ax
		sbb	dx,0
loc_107:

		pop	bx
		pop	si
		pop	di
		pop	bp
		retn	8
			                      
fourier_maybe		endp

new_ss_par		proc	near				;
;==========================================================================
;                              堆栈刷新函数
;==========================================================================
PARAMETER_1	=	4								; bp+4
PARAMETER_2	=	6								; bp+6
PARAMETER_3	=	8								; bp+8

		push	bp								
		mov	bp,sp								; 设置堆栈，为参数调用做准备
		push	bx								; 保存bx
		mov	bx,[bp+PARAMETER_1]					; 参数1 送bx
		push	word ptr [bp+PARAMETER_3]		; 保存参数3 为怪乘函数的参数4
		push	word ptr [bp+PARAMETER_2]		; 保存参数2 为怪乘函数的参数3
		push	word ptr ss:[bx+2]				; 将堆栈段内，以参数1 的数值为基址偏移2字节处的数据压栈
		push	word ptr ss:[bx]				; 将堆栈段内，以参数1 的数值为基址处的数据压栈
		call	bit_mult						; 怪乘上面的四个参数。
		mov	ss:[bx],ax							; 怪乘的结果保存于原来的堆栈参数1 基址处。
		mov	ss:[bx+2],dx						;
		pop	bx									;
		pop	bp									;
		retn	6								;
			                     
new_ss_par		endp

call_fourier	proc	near				; 参数1作为堆栈段内一个基址
;==========================================================================
;                            调用“傅立叶”
;==========================================================================
PARAMETER_1	=	4			; bp+4
PARAMETER_2	=	6			; bp+6
PARAMETER_3	=	8			; bp+8

		push	bp
		mov	bp,sp							; 准备堆栈传递参数
		push	bx							; 保存bx
		mov	bx,[bp+PARAMETER_1]
		push	word ptr [bp+PARAMETER_3]	; PARAMETER_4
		push	word ptr [bp+PARAMETER_2]	; PARAMETER_3
		push	word ptr ss:[bx+2]			; PARAMETER_2
		push	word ptr ss:[bx]			; PARAMETER_1
		call	fourier_maybe
		mov	ss:[bx+2],dx
		mov	ss:[bx],ax
		pop	bx
		pop	bp
		retn	6
		db	7	dup(0)	                       
call_fourier		endp
;--------------------------------------------------------------------------


cs_112C		dw	0, 0
cs_1130		dw	0							; segment storage
			db	0, 0
cs_1134		dw	0							; segment storage
cs_1136		dw	0
cs_1138		dw	0
cs_113A		db	0Eh							; Data table (indexed access)
			db	 0Eh, 0Eh, 0Dh
cs_113E		dw	0							; 某种标志
cs_1140		db	0							; 也是某种标志



set_timer_		proc	near				; 功能与set_time几乎相同，用来设置系统定时器

		push	ax
		mov	al,36h				; '6'
		out	43h,al				; port 43h, 8253 timer control
		pop	ax
		out	40h,al				; port 40h, 8253 timer 0 clock
		xchg	ah,al
		out	40h,al				; port 40h, 8253 timer 0 clock
		xchg	ah,al
		retn
		db 16 dup(0)			; 垃圾数据填充定位		
set_timer_		endp

call_settime	proc	near
;==========================================================================
;                              SUBROUTINE
;==========================================================================
PARAMETER_1	=	4					; bp+4


		push	bp
		mov	bp,sp
		mov	ax,[bp+PARAMETER_1]		; 音乐的缺省速率
		pushf						; Push flags
		cli							; Disable interrupts
		call	set_timer_
		popf						; Pop flags
		pop	bp
		retn
		db	20	dup(0)	                        
call_settime		endp

step			proc	near				; 一次性函数，仅仅被set_new_int调用
;==========================================================================
;                             这里是设置中断函数的重要地方
;==========================================================================
		push	ax
		push	dx
cs_1184:		
		xor	ax,ax						; 这里不能改，为什么呢？一定是这里的代码被其他的地方调用。
		call	set_timer_	
		mov	byte ptr cs:[1140h],0		; 这里也是，给一个初值。
		mov	ax,ds						; 这里很重要，将数据段地址送ax
		mov	cs:[1130h],ax				; 保存数据段首址（很大胆，用CS里面的数据当临时变量）
		push	es
		mov	ah,35h						; '5'
		mov	al,8						; 取8 号中断向量（时钟中断）
		int	21h							; DOS Services  ah=function 35h
										;  get intrpt vector al in es:bx
		mov	cs:[112Ch],bx				; 
		mov	cs:[112Eh],es				; 保存原来的中断向量
		pop	es
		push	ds
		mov	ah,25h						; '%'
		mov	al,8
		mov	dx,offset int_08h_entry		; 设置新的中断时钟中断向量
		mov	bx,cs
		mov	ds,bx						; 将cs 的值赋给ds
		int	21h							; DOS Services  ah=function 25h
										;  set intrpt vector al to ds:dx
		pop	ds
		pop	dx
		pop	ax
		retn
		db	15	dup(0)
step		endp

set_int			proc	near
		xor	ax,ax							; Zero register
		call	set_timer_
		push	ds
		mov	ah,25h							; '%'
		mov	al,8
		lds	dx,dword ptr cs:cs_112C			; Load seg:offset ptr
		int	21h								; DOS Services  ah=function 25h
											;  set intrpt vector al to ds:dx
		pop	ds
		retn
		db	15	dup(0)
set_int		endp			                     

int_08h_entry	proc	far					; 08号中断向量操作，step函数已经写好了代码
;==========================================================================
;
;                          自定义时钟中断处理函数
;
;==========================================================================

		push	ax
		xor ax,ax
		pushf							; Push flags
		call	dword ptr cs:[112Ch]	; 这里保存着原始8 号中断向量代码
		or	ax,1						; 这里应该是检测返回值吧？
about_rix:		
		cmp	word ptr cs:[113Eh],0		; 初值为0
		jg	short dont_rix				; Jump if >
		cmp	byte ptr cs:[1140h],0		; 用以判断rix文件是否已经成功载入。为0 表示没有载入，初始值为0。
		jne	short dont_rix				; Jump if not equal
		push	bx
		push	cx
		push	dx
		push	ds
		push	es
		push	si
		push	di
		push	bp
		mov	cs:[1134h],ss				; 保存原来的堆栈段
		mov	cs:[1136h],sp				; 保存原来的堆栈指针
		mov	ax,cs:[1130h]				; 原来的数据段地址
		mov	es,ax						; 数据段地址送es
		mov	ds,ax						; 数据段地址送ds
		mov	ss,ax						; 数据段地址送ss
		mov	sp,3BAh						; 明白了，用堆栈的方式来操作原来数据段的数据了。
		inc	byte ptr cs:[1140h]			; 表示rix文件已经处理了。
		sti								; Enable interrupts
		call	rix_proc
		cli								; Disable interrupts
		or	ax,ax						; 一般是rix文件操作完后为0
		jz	short fover_maybe			; Jump if zero，大概是说rix处理失败
		add	cs:[113Eh],ax
fover_maybe:
		dec	byte ptr cs:[1140h]			; 保持cs;[1140]为0 值？
		mov	bx,cs:[1134h]
		mov	ss,bx						; 恢复堆栈
		mov	sp,cs:[1136h]				; 恢复堆栈指针
		sti								; Enable interrupts
		pop	bp
		pop	di
		pop	si
		pop	es
		pop	ds
		pop	dx
		pop	cx
		pop	bx
		or	ax,ax						; Zero ?
		jz	short rix_finish			; Jump if zero
		jmp	short about_rix				; rix 文件还没有搞定
dont_rix:
		or	ax,ax						; Zero ?
		jz	short rix_finish			; Jump if zero
		push	bx
		mov	bx,cs:[1138h]
		mov	al,cs:[113Ah][bx]
		xor	ah,ah						; Zero register
		sub	cs:[113Eh],ax
		and	bx,3
		mov	cs:[1138h],bx
		pop	bx
rix_finish:
		pop	ax
		iret							; Interrupt return
		db	23	dup(0)	                        
int_08h_entry	endp
;--------------------------------------------------------------------------

code_seg		ends



;------------------------------------------------------------ data_seg ----

data_seg		segment	byte public use16					; 相当于cs:1290
		assume cs:data_seg  , ds:data_seg , ss:stack_seg

			                        ; now data because: found data
data_70		dw	10 dup (0)
in_filename		db	2Eh										; 输入的文件名就保存在这里
			db	 52h, 49h, 58h, 00h
buf_addr	dw	0
_title		db	'PlayRix Version 1.01 ](TUBRO Ver'
			db	'sion)[', 0Dh, 0Ah, 'Program writ'
			db	'en by Pei-Cheng '
data_75		db  'Tong using assem'
			db	'bly 1994.', 0Dh, 0Ah, 0Dh, 0Ah, '['
			db	'P]:Pause [C]:Continue [+,-]:Chan'
			db	'g Speed', 0Dh, 0Ah, '[CTRL] --->'
			db	' Stop and End.', 0Dh, 0Ah, '$'
usage		db	0Dh, 0Ah, 'Usage: PlayRix [FileNa'   
			db	'me].Rix.', 0Dh, 0Ah, '$'
mus_time	dw	4268h								; 音乐的速率！
data_78		db	0									; 相对于data_seg 偏移了E7h
			dw	0			
			; Data table (indexed access)
	
			;db	 9  dup(0)
			db	 00h, 00h, 00h, 00h, 10h, 08h		
			db	 04h, 02h, 01h
			;db	 72  dup(0) 
			db	 00h 
ds_F4		db   01h, 01h							; 这里很可能是乐器库数据！
			db	 03h, 0Fh, 05h, 00h, 01h, 03h
			db	 0Fh, 00h, 00h, 00h, 01h, 00h
			db	 00h, 01h, 01h, 0Fh, 07h, 00h
			db	 02h, 04h, 00h, 00h, 00h, 01h
			db	 00h, 00h, 00h, 00h, 00h, 0Ah
			db	 04h, 00h, 08h, 0Ch, 0Bh, 00h
			db	 00h, 00h, 01h, 00h, 00h, 00h
			db	 00h, 0Dh, 04h, 00h, 06h, 0Fh
			db	 00h, 00h, 00h, 00h, 01h, 00h
			db	 00h, 0Ch, 00h, 0Fh, 0Bh, 00h		
			db	 08h, 05h
			db	7 dup (0)							; 到这里共72个字节
			;db		69 dup(0)
			db	 04h, 00h, 0Fh, 0Bh, 00h, 07h		; 这里大概是旋律乐音数据！
			db	 05h, 00h, 00h, 00h, 00h, 00h
			db	 00h, 00h, 01h, 00h, 0Fh, 0Bh
			db	 00h, 05h, 05h, 00h, 00h, 00h
			db	 00h, 00h, 00h, 00h, 01h, 00h
			db	 0Fh, 0Bh, 00h, 07h, 05h, 00h
			db	 00h, 00h, 00h, 00h, 00h, 00h
			db	 03h, 01h, 04h, 02h, 05h, 06h
			db	 09h, 07h, 0Ah, 08h, 0Bh, 0Ch
			db	 0Fh, 0Dh, 10h, 0Eh, 11h, 0Ch
			db	 0Fh, 10h, 00h, 0Eh, 00h, 11h		
			db	 00h, 0Dh, 00h						; 到这里共69个字节
reg_data		db	0			
			; Data table (indexed access)
			db	 01h, 02h, 03h, 04h, 05h, 08h
			db	 09h, 0Ah, 0Bh, 0Ch, 0Dh, 10h
			db	 11h, 12h, 13h, 14h, 15h
ins_maybe	db	0									; 这里莫非是INS文件的数据？
			db	0, 0, 1, 1, 1, 0
			db	0, 0, 1, 1, 1, 0
			db	0, 0, 1, 1, 1
ad_data_c0		db	0			
			; Data table (indexed access)
			db	 01h, 02h, 00h, 01h, 02h, 03h
			db	 04h, 05h, 03h, 04h, 05h, 06h
			db	 07h, 08h, 06h, 07h, 08h,0FFh
			db	0FFh, 00h, 00h

data_seg		ends								; 1B8（440）个字节



;------------------------------------------------------  stack_seg   ----

stack_seg	segment	word stack 'STACK' use16

		db	1024 dup (0)
stack_seg	ends



		end	start
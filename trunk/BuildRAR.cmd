rem 删除无用文件
del /s /q *.rar *.bak
del /s /q /a:-RSHA thumbs.db

rem 备份Map相关
cd MapEditor
move gop ..\bak
move map ..\bak
move *.mkf ..\bak

rem 移除script结果
cd ..\PalScript
del /q *.*.txt original.txt *.bin sss.mkf m.msg word.dat
move sss0R ..\bak

cd ..
move bak ..

rem 赶紧打包去~
path %path%;"D:\Program Files\WinRAR"
rar a -m5 -s -r research.rar *.*
pause

move ..\bak

rem 还原map相关
cd MapEditor
move ..\bak\gop
move ..\bak\map
move ..\bak\pat.mkf

rem 重生成script
cd ..\Palscript
call makeall.cmd
move ..\bak\sss0R
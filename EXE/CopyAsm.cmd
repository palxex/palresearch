setlocal enabledelayedexpansion
set "src=E:\Game\palresearch\EXE\asm"
set "dst=E:\liuzhier\HTML\PalModWiki\page\asm"

if not exist "%dst%" mkdir "%dst%"

for %%F in ("%src%\*.asm") do (
    set "outfile=%dst%\%%~nF.html"
    :: 注意：这里必须用 ^ 转义 < 和 >，否则 CMD 会以为你在重定向
    echo ^<pre^> > "!outfile!"
    type "%%F" >> "!outfile!"
    echo ^</pre^> >> "!outfile!"
)

"E:\liuzhier\HTML\PalModWiki\AutoPush.bat"
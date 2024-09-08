@echo off
setlocal enabledelayedexpansion

echo #####################################
echo ### Split Images to LINE Stickers ###
echo ###           cc: dododo-shirouto ###
echo #####################################



rem ImageMagickのバージョン確認
magick -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ImageMagick is not installed.
    echo download URL: https://imagemagick.org/script/download.php#windows
    pause
    exit /b
)



rem ドラッグ＆ドロップされたファイルを変数に設定
set INPUT_IMAGE=%1

rem ファイルが指定されていない場合、入力を促す
if "%INPUT_IMAGE%"=="" (
    set /p INPUT_IMAGE=Image file path:
    @REM set INPUT_IMAGE=test.png
)



rem 入力ファイルが存在するか確認
if not exist "%INPUT_IMAGE%" (
    echo File not found: %INPUT_IMAGE%
    pause
    exit /b
)



rem 画像の幅と高さを取得する
for /f "tokens=1,2 delims=x " %%a in ('magick identify -format "%%w %%h" "%INPUT_IMAGE%"') do (
    set IMG_WIDTH=%%a
    set IMG_HEIGHT=%%b
)

rem 画像サイズを確認
set /a IMAGES_NUM=0
if %IMG_WIDTH%==1580 (
    if %IMG_HEIGHT%==960 set /a IMAGES_NUM=8
    if %IMG_HEIGHT%==1640 set /a IMAGES_NUM=16
    if %IMG_HEIGHT%==2320 set /a IMAGES_NUM=24
    if %IMG_HEIGHT%==3000 set /a IMAGES_NUM=32
    if %IMG_HEIGHT%==3680 set /a IMAGES_NUM=40
)

if %IMAGES_NUM%==0 (
    echo Image size is not supported: %IMG_WIDTH%x%IMG_HEIGHT%
    pause
    exit /b
)

echo Number of images: %IMAGES_NUM%



rem 画像サイズとマージンを設定
set MAIN_WIDTH=240
set MAIN_HEIGHT=240
set TAB_WIDTH=96
set TAB_HEIGHT=74
set IMG_WIDTH=370
set IMG_HEIGHT=320
set PAGE_MARGIN=20
set GRID_MARGIN=20

set NOW_X=%PAGE_MARGIN%
set NOW_Y=%PAGE_MARGIN%

rem 入力ファイルのファイル名（拡張子を除いた部分）を取得
for %%f in ("%INPUT_IMAGE%") do set FILENAME=%%~nf

rem 出力ディレクトリを設定（入力ファイルの名前を使う）
set OUTPUT_DIR=%FILENAME%
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"



rem main.pngを切り出し
magick "%INPUT_IMAGE%" -crop %MAIN_WIDTH%x%MAIN_HEIGHT%+%NOW_X%+%NOW_Y% "%OUTPUT_DIR%\main.png"

rem tab.pngを切り出し
set /a NOW_X=%NOW_X%+%MAIN_WIDTH%+%GRID_MARGIN%
magick "%INPUT_IMAGE%" -crop %TAB_WIDTH%x%TAB_HEIGHT%+%NOW_X%+%NOW_Y% "%OUTPUT_DIR%\tab.png"

set /a NOW_Y=%NOW_Y% + %MAIN_HEIGHT% + %GRID_MARGIN%
set /a NOW_X=%PAGE_MARGIN%
@REM echo X:%NOW_X% Y:%NOW_Y%


rem 4行x5列のグリッドで画像を切り出し

set /a COL_COUNT=4
set /a ROW_COUNT=%IMAGES_NUM%/%COL_COUNT%

set /a CURRENT_INDEX=1

for /l %%x in (1,1,%ROW_COUNT%) do (
    for /l %%y in (1,1,%COL_COUNT%) do (
        set /a FILE_INDEX=!CURRENT_INDEX!
        set FILE_NUM=00!FILE_INDEX!
        set FILE_NUM=!FILE_NUM:~-2!
        magick "%INPUT_IMAGE%" -crop !IMG_WIDTH!x!IMG_HEIGHT!+!NOW_X!+!NOW_Y! "%OUTPUT_DIR%\!FILE_NUM!.png"
        set /a CURRENT_INDEX+=1
        set /a NOW_X=!NOW_X! + !IMG_WIDTH! + !GRID_MARGIN!
    )
    set /a NOW_Y=!NOW_Y! + !IMG_HEIGHT! + !GRID_MARGIN!
    set /a NOW_X=%PAGE_MARGIN%
)

echo Done!
@REM pause
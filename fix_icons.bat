@echo off
set SRC=C:\Users\Desktop\Projects\stira\assets\icon\app_icon.png
for /D %%d in (C:\Users\Desktop\Projects\stira\android\app\src\main\res\mipmap-*) do (
    copy /Y "%SRC%" "%%d\ic_calculator.png"
    copy /Y "%SRC%" "%%d\ic_finance.png"
    copy /Y "%SRC%" "%%d\ic_notes.png"
    copy /Y "%SRC%" "%%d\ic_weather.png"
    copy /Y "%SRC%" "%%d\ic_launcher.png"
    copy /Y "%SRC%" "%%d\launcher_icon.png"
)
echo Icons replaced successfully.

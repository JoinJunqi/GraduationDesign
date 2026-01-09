@echo off
echo.
echo [信息] 启动医院管理子模块...
echo.

%~d0
cd %~dp0

cd ../ruoyi-modules/ruoyi-modules-doctor/target
start "RuoYi-Doctor" java -Dfile.encoding=utf-8 -Xms256m -Xmx512m -jar ruoyi-modules-doctor.jar

cd ../../ruoyi-modules-patient/target
start "RuoYi-Patient" java -Dfile.encoding=utf-8 -Xms256m -Xmx512m -jar ruoyi-modules-patient.jar

cd ../../ruoyi-modules-appointment/target
start "RuoYi-Appointment" java -Dfile.encoding=utf-8 -Xms256m -Xmx512m -jar ruoyi-modules-appointment.jar

cd ../../ruoyi-modules-department/target
start "RuoYi-Department" java -Dfile.encoding=utf-8 -Xms256m -Xmx512m -jar ruoyi-modules-department.jar

cd ../../ruoyi-modules-schedule/target
start "RuoYi-Schedule" java -Dfile.encoding=utf-8 -Xms256m -Xmx512m -jar ruoyi-modules-schedule.jar

cd ../../ruoyi-modules-record/target
start "RuoYi-Record" java -Dfile.encoding=utf-8 -Xms256m -Xmx512m -jar ruoyi-modules-record.jar

cd ../../../bin
echo [信息] 医院管理子模块启动命令已下发
pause

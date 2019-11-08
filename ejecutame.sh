#se ejecuta este comando como ./ejecutame.sh nombre_usuario contraseña
mysql -hlocalhost -u$1 -p$2 test_TP < BD.sql
/*
 * Creacion de la Base de datos
 */
CREATE DATABASE text_TP;

/*
 * Creacion de Tablas y sus PK y FK
 */
CREATE TABLE Categoria(
    id_categoria int unsigned NOT NULL AUTO_INCREMENT,
    descripcion varchar(20) NOT NULL,
    porcentaje float NOT NULL,
    PRIMARY KEY(id_categoria)
);


CREATE TABLE Se_Inscribe(
    nro_socio int unsigned NOT NULL,
    id_clase int unsigned NOT NULL,
    PRIMARY KEY(nro_socio, id_clase),
    FOREIGN KEY(nro_socio),
    FOREIGN KEY(id_clase)
);


CREATE TABLE Arancelada(
    cod_actividad int unsigned NOT NULL,
    costo float NOT NULL,
    periodo_pago varchar(20) NOT NULL,
    PRIMARY KEY(cod_actividad)
);


CREATE TABLE Puede_Desarrollarse_En(
    cod_actividad int unsigned NOT NULL,
    cod_area int unsigned NOT NULL,
    PRIMARY KEY(cod_actividad, cod_area),
    FOREIGN KEY(cod_actividad),
    FOREIGN KEY(cod_area)
);


CREATE TABLE Profesional(
    legajo int unsigned NOT NULL AUTO_INCREMENT,
    nombre varchar(20) NOT NULL,
    apellido varchar(20) NOT NULL,
    dni varchar(11) NOT NULL,
    fecha_nac date NOT NULL,
    especializacion varchar(20) NOT NULL,
    PRIMARY KEY(legajo)
);



CREATE TABLE Titular(
    nro_socio int unsigned NOT NULL AUTO_INCREMENT,
    nombre varchar(20) NOT NULL,
    apellido varchar(20) NOT NULL,
    email varchar(30) NOT NULL,
    fech_nac date NOT NULL,
    domicilio varchar(20) NOT NULL,
    celular char(11) NOT NULL,
    telefono char(11) NOT NULL,
    PRIMARY KEY(nro_socio)
);

CREATE TABLE Familiar(
    nro_socio int unsigned NOT NULL,
    nro_orden int unsigned NOT NULL AUTO_INCREMENT,
    nombre varchar(20) NOT NULL,
    apellido varchar(20) NOT NULL,
    id_categoria int NOT NULL,
    fecha_nac date NOT NULL,
    email varchar(30) NOT NULL,
    celular char(11) NOT NULL,
    PRIMARY KEY(nro_socio, nro_orden),
    FOREIGN KEY(nro_socio)
);

CREATE TABLE Cuota(
    id_cuota int unsigned NOT NULL AUTO_INCREMENT,
    monto_base float(8),
    periodo varchar(20) NOT NULL,
    PRIMARY KEY(id_cuota)
);

CREATE TABLE Pago(
    id_cuota int NOT NULL,
    nro_socio int NOT NULL,
    nro_pago int unsigned NOT NULL AUTO_INCREMENT,
    monto_abonado float NOT NULL,
    fecha_vencimiento date NOT NULL,
    monto_pagar float NOT NULL,
    fecha_pago date NOT NULL,
    PRIMARY KEY (nro_socio, nro_pago),
    FOREIGN KEY (id_cuota),
    FOREIGN KEY (nro_socio)
);

CREATE TABLE Clase(
    id_clase int unsigned NOT NULL AUTO_INCREMENT,
    horario NOT NULL,
    día Date NOT NULL,
    cod_actividad int NOT NULL,
    cod_área int NOT NULL,
    periodo varchar(20),
    PRIMARY KEY(id_clase),
    FOREIGN KEY(cod_actividad),
    FOREIGN KEY(cod_area)
);

CREATE TABLE Actividad(
    cod_actividad int unsigned NOT NULL AUTO_INCREMENT,
    descripción varchar(50),
    nombre varchar(20) NOT NULL,
    tipo_costo varchar(20),
    id_categoría int NOT NULL,
    PRIMARY KEY(cod_actividad),
    FOREIGN KEY(id_categoría)
);

CREATE TABLE Area(
    cod_area int unsigned NOT NULL AUTO_INCREMENT,
    ubicacion varchar(20) NOT NULL,
    capacidad int NOT NULL,
    estado varchar(20),
    PRIMARY KEY(cod_area)
);

CREATE TABLE Paga_t(
    nro_socio int NOT NULL,
    cod_actividad int NOT NULL,
    fecha date NOT NULL,
    monto float NOT NULL,
    PRIMARY KEY (nro_socio, cod_actividad),
    FOREIGN KEY (cod_actividad),
    FOREIGN KEY (nro_socio)
);

CREATE TABLE Paga_F(
    nro_socio int NOT NULL,
    nro_orden int NOT NULL,
    cod_actividad int NOT NULL,
    fecha Date NOT NULL,
    monto float(8) NOT NULL,
    PRIMARY KEY (nro_socio, nro_orden, cod_actividad),
    FOREIGN KEY (cod_actividad),
    FOREIGN KEY (nro_socio, nro_orden)
);

CREATE TABLE Dirige(
    legajo int NOT NULL,
    id_clase int NOT NULL,
    PRIMARY KEY(legajo, id_clase),
    FOREIGN KEY(legajo),
    FOREIGN KEY(id_clase)
);

CREATE TABLE A_cargo_de(
    cod_actividad int NOT NULL,
    legajo int NOT NULL,
    PRIMARY KEY(cod_actividad, legajo),
    FOREIGN KEY(legajo),
    FOREIGN KEY(cod_actividad)
);

_______________________________________________________________________________________________________________________



INSERT INTO Profesional(legajo,nombre,apellido,dni,fecha_nac,especializacion)
VALUES ('454553','matias','suarez','16589236','1978/2/10','tenis');

INSERT INTO Profesional(legajo,nombre,apellido,dni,fecha_nac,especializacion)
VALUES ('478961','juana','lopez','19589274','1983/6/12','edfisica');

INSERT INTO Profesional(legajo,nombre,apellido,dni,fecha_nac,especializacion)
VALUES ('785963','marina','fernandez','35587885','1992/9/16','futbol');

INSERT INTO Profesional(legajo,nombre,apellido,dni,fecha_nac,especializacion)
VALUES ('157896','julio','martinez','42558971','1998/8/10','hockey');

INSERT INTO Profesional(legajo,nombre,apellido,dni,fecha_nac,especializacion)
VALUES ('478163','guillermina','villa','32589657','1988/5/2','tenis');

INSERT INTO Profesional(legajo,nombre,apellido,dni,fecha_nac,especializacion)
VALUES ('147852','fernando','gomez','39174589','1995/2/6','futbol');

INSERT INTO Profesional(legajo,nombre,apellido,dni,fecha_nac,especializacion)
VALUES ('454123','mateo','mariani','29885741','1989/3/11','edfisica');

INSERT INTO Profesional(legajo,nombre,apellido,dni,fecha_nac,especializacion)
VALUES ('851173','karen','juarez','39887414','1996/12/20','edfisica');

INSERT INTO Profesional(legajo,nombre,apellido,dni,fecha_nac,especializacion)
VALUES ('589633','mirta','hernandez','30188941','1985/7/24','natacion');

INSERT INTO Profesional(legajo,nombre,apellido,dni,fecha_nac,especializacion)
VALUES ('474583','diego','rios','38182236','1980/10/30','natacion');
______________


INSERT INTO Categoria(id_categoria,descripcion,porcentaje)
VALUES ('1','infantil,'0.15');
INSERT INTO Categoria(id_categoria,descripcion,porcentaje)
VALUES ('2','mayor','0.2');
INSERT INTO Categoria(id_categoria,descripcion,porcentaje)
VALUES ('3','vitalicio,'0');
_______________

INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('100','1');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('100','3');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('101','1');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('102','1');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('102','2');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('103','2');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('104','1');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('104','3');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('104','6');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('105','5');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('106','4');
INSERT INTO Se_Inscribe(nro_socio, id_clase)
VALUES ('106','5');
_______________

INSERT INTO Arancelada(cod_actividad,costo,periodo_pago)
VALUES ('5','200',?)
INSERT INTO Arancelada(cod_actividad,costo,periodo_pago)
VALUES ('4','200',?)
_______________

INSERT INTO Puede_Desarrollarse_En(cod_actividad,cod_area)
VALUES ('1','1');
INSERT INTO Puede_Desarrollarse_En(cod_actividad,cod_area)
VALUES ('1','5');
INSERT INTO Puede_Desarrollarse_En(cod_actividad,cod_area)
VALUES ('2','1');
INSERT INTO Puede_Desarrollarse_En(cod_actividad,cod_area)
VALUES ('3','1');
INSERT INTO Puede_Desarrollarse_En(cod_actividad,cod_area)
VALUES ('3','2');
INSERT INTO Puede_Desarrollarse_En(cod_actividad,cod_area)
VALUES ('4','4');
INSERT INTO Puede_Desarrollarse_En(cod_actividad,cod_area)
VALUES ('5','3');

______________


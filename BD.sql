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

CREATE TABLE Puede_Desarrolarse_En(
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
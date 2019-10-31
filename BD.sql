DROP DATABASE test_TP;
CREATE DATABASE test_TP;
USE test_TP;

/*
 * Creacion de Tablas y sus PK y FK
 */
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

/* hay que tener cuidado por que aca el numero de orden hay que ir aumentandolo a mano*/
CREATE TABLE Familiar(
    nro_socio int unsigned NOT NULL,
    nro_orden int unsigned NOT NULL,
    nombre varchar(20) NOT NULL,
    apellido varchar(20) NOT NULL,
    id_categoria int NOT NULL,
    fecha_nac date NOT NULL,
    email varchar(30) NOT NULL,
    celular varchar(11) NOT NULL,
    PRIMARY KEY(nro_socio, nro_orden),
    FOREIGN KEY(nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE
);

CREATE TABLE Categoria(
    id_categoria int unsigned NOT NULL AUTO_INCREMENT,
    descripcion varchar(20) NOT NULL,
    porcentaje float NOT NULL,
    PRIMARY KEY(id_categoria)
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

CREATE TABLE Area(
    cod_area int unsigned NOT NULL AUTO_INCREMENT,
    ubicacion varchar(20) NOT NULL,
    capacidad int NOT NULL,
    estado varchar(20),
    PRIMARY KEY(cod_area)
);

CREATE TABLE Actividad(
    cod_actividad int unsigned NOT NULL AUTO_INCREMENT,
    descripción varchar(50),
    nombre varchar(20) NOT NULL,
    tipo_costo varchar(20),
    id_categoria int unsigned NOT NULL,
    PRIMARY KEY(cod_actividad),
    FOREIGN KEY(id_categoria) REFERENCES Categoria(id_categoria) ON DELETE CASCADE
);

CREATE TABLE Clase(
    id_clase int unsigned NOT NULL AUTO_INCREMENT,
    dia_y_hora datetime NOT NULL,
    cod_actividad int unsigned NOT NULL,
    cod_area int unsigned NOT NULL,
    periodo varchar(20),
    PRIMARY KEY(id_clase),
    FOREIGN KEY(cod_actividad) REFERENCES Actividad(cod_actividad) ON DELETE CASCADE,
    FOREIGN KEY(cod_area) REFERENCES Area(cod_area) ON DELETE CASCADE
);

CREATE TABLE Arancelada(
    cod_actividad int unsigned NOT NULL,
    costo float NOT NULL,
    periodo_pago varchar(20) NOT NULL,
    PRIMARY KEY(cod_actividad)
);

CREATE TABLE Cuota(
    id_cuota int unsigned NOT NULL AUTO_INCREMENT,
    monto_base float(8),
    periodo varchar(20) NOT NULL,
    PRIMARY KEY(id_cuota)
);

#mismo problema que familiar
CREATE TABLE Pago(
    id_cuota int unsigned NOT NULL,
    nro_socio int unsigned NOT NULL,
    nro_pago int unsigned NOT NULL,
    monto_abonado float NOT NULL,
    fecha_vencimiento date NOT NULL,
    monto_pagar float NOT NULL,
    fecha_pago date NOT NULL,
    PRIMARY KEY (nro_socio, nro_pago),
    FOREIGN KEY (id_cuota) REFERENCES Cuota(id_cuota) ON DELETE CASCADE,
    FOREIGN KEY (nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE
);

CREATE TABLE Se_Inscribe_t(
    nro_socio int unsigned NOT NULL,
    id_clase int unsigned NOT NULL,
    PRIMARY KEY(nro_socio, id_clase),
    FOREIGN KEY(nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE,
    FOREIGN KEY(id_clase) REFERENCES Clase(id_clase) ON DELETE CASCADE
);

CREATE TABLE Se_Inscribe_f(
    nro_socio int unsigned NOT NULL,
    nro_orden int unsigned NOT NULL,
    id_clase int unsigned NOT NULL,
    PRIMARY KEY(nro_socio, id_clase),
    FOREIGN KEY(nro_socio, nro_orden) REFERENCES Familiar(nro_socio, nro_orden) ON DELETE CASCADE,
    FOREIGN KEY(id_clase) REFERENCES Clase(id_clase) ON DELETE CASCADE
);

CREATE TABLE Puede_Desarrollarse_En(
    cod_actividad int unsigned NOT NULL,
    cod_area int unsigned NOT NULL,
    PRIMARY KEY(cod_actividad, cod_area),
    FOREIGN KEY(cod_actividad) REFERENCES Actividad(cod_actividad) ON DELETE CASCADE,
    FOREIGN KEY(cod_area) REFERENCES Area(cod_area) ON DELETE CASCADE
);

CREATE TABLE Paga_t(
    nro_socio int unsigned NOT NULL,
    cod_actividad int unsigned NOT NULL,
    fecha date NOT NULL,
    monto float NOT NULL,
    PRIMARY KEY (nro_socio, cod_actividad),
    FOREIGN KEY (cod_actividad) REFERENCES Actividad(cod_actividad) ON DELETE CASCADE,
    FOREIGN KEY (nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE
);

CREATE TABLE Paga_f(
    nro_socio int unsigned NOT NULL,
    nro_orden int unsigned NOT NULL,
    cod_actividad int unsigned NOT NULL,
    fecha Date NOT NULL,
    monto float(8) NOT NULL,
    PRIMARY KEY (nro_socio, nro_orden, cod_actividad),
    FOREIGN KEY (cod_actividad) REFERENCES Actividad(cod_actividad) ON DELETE CASCADE,
    FOREIGN KEY (nro_socio, nro_orden) REFERENCES Familiar(nro_socio, nro_orden) ON DELETE CASCADE
);

CREATE TABLE Dirige(
    legajo int unsigned NOT NULL,
    id_clase int unsigned NOT NULL,
    PRIMARY KEY(legajo, id_clase),
    FOREIGN KEY(legajo) REFERENCES Profesional(legajo) ON DELETE CASCADE,
    FOREIGN KEY(id_clase) REFERENCES Clase(id_clase) ON DELETE CASCADE
);

CREATE TABLE Capacitado_para(
    cod_actividad int unsigned NOT NULL,
    legajo int unsigned NOT NULL,
    PRIMARY KEY(cod_actividad, legajo),
    FOREIGN KEY(legajo) REFERENCES Profesional(legajo) ON DELETE CASCADE,
    FOREIGN KEY(cod_actividad) REFERENCES Actividad(cod_actividad) ON DELETE CASCADE
);

_______________________________________________________________________________________________________________________
INSERT INTO
    Profesional(
        legajo,
        nombre,
        apellido,
        dni,
        fecha_nac,
        especializacion
    )
VALUES
    (
        '454553',
        'matias',
        'suarez',
        '16589236',
        '1978/2/10',
        'tenis'
    ),
    (
        '478961',
        'juana',
        'lopez',
        '19589274',
        '1983/6/12',
        'edfisica'
    ),
    (
        '785963',
        'marina',
        'fernandez',
        '35587885',
        '1992/9/16',
        'futbol'
    ),
    (
        '157896',
        'julio',
        'martinez',
        '42558971',
        '1998/8/10',
        'hockey'
    ),
    (
        '478163',
        'guillermina',
        'villa',
        '32589657',
        '1988/5/2',
        'tenis'
    ),
    (
        '147852',
        'fernando',
        'gomez',
        '39174589',
        '1995/2/6',
        'futbol'
    ),
    (
        '454123',
        'mateo',
        'mariani',
        '29885741',
        '1989/3/11',
        'edfisica'
    ),
    (
        '851173',
        'karen',
        'juarez',
        '39887414',
        '1996/12/20',
        'edfisica'
    ),
    (
        '589633',
        'mirta',
        'hernandez',
        '30188941',
        '1985/7/24',
        'natacion'
    ),
    (
        '474583',
        'diego',
        'rios',
        '38182236',
        '1980/10/30',
        'natacion'
    );

______________
INSERT INTO
    Categoria(id_categoria, descripcion, porcentaje)
VALUES
    ('1', 'infantil', '0.15'),
    ('2', 'mayor', '0.2'),
    ('3', 'vitalicio', '0');

_______________ #hay que insertar titulares para que se puedan inscribir en una clase
INSERT INTO
    Se_Inscribe(nro_socio, id_clase)
VALUES
    ('100', '1'),
    ('100', '3'),
    ('101', '1'),
    ('102', '1'),
    ('102', '2'),
    ('103', '2'),
    ('104', '1'),
    ('104', '3'),
    ('104', '6'),
    ('105', '5'),
    ('106', '4'),
    ('106', '5');

_______________
INSERT INTO
    Arancelada(cod_actividad, costo, periodo_pago)
VALUES
    ('5', '200', ?),
    ('4', '200', ?);

_______________
INSERT INTO
    Puede_Desarrollarse_En(cod_actividad, cod_area)
VALUES
    ('1', '1'),
    ('1', '5'),
    ('2', '1'),
    ('3', '1'),
    ('3', '2'),
    ('4', '4'),
    ('5', '3');

______________
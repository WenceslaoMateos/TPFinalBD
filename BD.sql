DROP DATABASE test_TP;

CREATE DATABASE test_TP;

USE test_TP;

/*
 * Creacion de Tablas y sus PK y FK
 */
CREATE TABLE Categoria(
    id_categoria varchar(15) NOT NULL,
    descripcion varchar(20) NOT NULL,
    porcentaje float NOT NULL,
    PRIMARY KEY(id_categoria)
);

CREATE TABLE Titular(
    nro_socio varchar(15) NOT NULL,
    id_categoria varchar(15) NOT NULL,
    nombre varchar(20) NOT NULL,
    apellido varchar(20) NOT NULL,
    fecha_nac date NOT NULL,
    email varchar(30),
    celular char(11),
    telefono char(11) NOT NULL,
    domicilio varchar(20) NOT NULL,
    PRIMARY KEY(nro_socio),
    FOREIGN KEY(id_categoria) REFERENCES Categoria(id_categoria) ON DELETE CASCADE
);

/* hay que tener cuidado por que aca el numero de orden hay que ir aumentandolo a mano*/
CREATE TABLE Familiar(
    nro_socio varchar(15) NOT NULL,
    nro_orden varchar(15) NOT NULL,
    id_categoria varchar(15) NOT NULL,
    nombre varchar(20) NOT NULL,
    apellido varchar(20) NOT NULL,
    fecha_nac date NOT NULL,
    email varchar(30),
    celular varchar(11),
    PRIMARY KEY(nro_socio, nro_orden),
    FOREIGN KEY(nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE,
    FOREIGN KEY(id_categoria) REFERENCES Categoria(id_categoria) ON DELETE CASCADE
);

CREATE TABLE Profesional(
    legajo varchar(15) NOT NULL,
    nombre varchar(20) NOT NULL,
    apellido varchar(20) NOT NULL,
    dni varchar(11) NOT NULL,
    fecha_nac date NOT NULL,
    especializacion varchar(20) NOT NULL,
    PRIMARY KEY(legajo)
);

CREATE TABLE Area(
    cod_area varchar(15) NOT NULL,
    ubicacion varchar(20) NOT NULL,
    capacidad int NOT NULL,
    estado varchar(20),
    PRIMARY KEY(cod_area)
);

CREATE TABLE Actividad(
    cod_actividad varchar(15) NOT NULL,
    descripción varchar(50),
    nombre varchar(20) NOT NULL,
    arancelada boolean NOT NULL,
    id_categoria varchar(15) NOT NULL,
    PRIMARY KEY(cod_actividad),
    FOREIGN KEY(id_categoria) REFERENCES Categoria(id_categoria) ON DELETE CASCADE
);

CREATE TABLE Clase(
    id_clase varchar(15) NOT NULL,
    dia_y_hora datetime NOT NULL,
    cod_actividad varchar(15) NOT NULL,
    cod_area varchar(15) NOT NULL,
    periodo varchar(20),
    PRIMARY KEY(id_clase),
    FOREIGN KEY(cod_actividad) REFERENCES Actividad(cod_actividad) ON DELETE CASCADE,
    FOREIGN KEY(cod_area) REFERENCES Area(cod_area) ON DELETE CASCADE
);

CREATE TABLE Arancelada(
    cod_actividad varchar(15) NOT NULL,
    costo float NOT NULL,
    periodo_pago varchar(20) NOT NULL,
    PRIMARY KEY(cod_actividad)
);

CREATE TABLE Cuota(
    id_cuota varchar(15) NOT NULL,
    monto_base float(8),
    periodo varchar(20) NOT NULL,
    PRIMARY KEY(id_cuota)
);

#mismo problema que familiar
CREATE TABLE Pago(
    id_cuota varchar(15) NOT NULL,
    nro_socio varchar(15) NOT NULL,
    nro_pago varchar(15) NOT NULL,
    monto_abonado float NOT NULL,
    fecha_vencimiento date NOT NULL,
    monto_pagar float NOT NULL,
    fecha_pago date NOT NULL,
    PRIMARY KEY (nro_socio, nro_pago),
    FOREIGN KEY (id_cuota) REFERENCES Cuota(id_cuota) ON DELETE CASCADE,
    FOREIGN KEY (nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE
);

CREATE TABLE Se_Inscribe_t(
    nro_socio varchar(15) NOT NULL,
    id_clase varchar(15) NOT NULL,
    PRIMARY KEY(nro_socio, id_clase),
    FOREIGN KEY(nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE,
    FOREIGN KEY(id_clase) REFERENCES Clase(id_clase) ON DELETE CASCADE
);

CREATE TABLE Se_Inscribe_f(
    nro_socio varchar(15) NOT NULL,
    nro_orden varchar(15) NOT NULL,
    id_clase varchar(15) NOT NULL,
    PRIMARY KEY(nro_socio, id_clase),
    FOREIGN KEY(nro_socio, nro_orden) REFERENCES Familiar(nro_socio, nro_orden) ON DELETE CASCADE,
    FOREIGN KEY(id_clase) REFERENCES Clase(id_clase) ON DELETE CASCADE
);

CREATE TABLE Puede_Desarrollarse_En(
    cod_actividad varchar(15) NOT NULL,
    cod_area varchar(15) NOT NULL,
    PRIMARY KEY(cod_actividad, cod_area),
    FOREIGN KEY(cod_actividad) REFERENCES Actividad(cod_actividad) ON DELETE CASCADE,
    FOREIGN KEY(cod_area) REFERENCES Area(cod_area) ON DELETE CASCADE
);

CREATE TABLE Paga_t(
    nro_socio varchar(15) NOT NULL,
    id_clase varchar(15) NOT NULL,
    fecha date NOT NULL,
    monto float NOT NULL,
    PRIMARY KEY (nro_socio, id_clase),
    FOREIGN KEY (id_clase) REFERENCES Clase(id_clase) ON DELETE CASCADE,
    FOREIGN KEY (nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE
);

CREATE TABLE Paga_f(
    nro_socio varchar(15) NOT NULL,
    nro_orden varchar(15) NOT NULL,
    id_clase varchar(15) NOT NULL,
    fecha Date NOT NULL,
    monto float(8) NOT NULL,
    PRIMARY KEY (nro_socio, nro_orden, id_clase),
    FOREIGN KEY (id_clase) REFERENCES Clase(id_clase) ON DELETE CASCADE,
    FOREIGN KEY (nro_socio, nro_orden) REFERENCES Familiar(nro_socio, nro_orden) ON DELETE CASCADE
);

CREATE TABLE Dirige(
    legajo varchar(15) NOT NULL,
    id_clase varchar(15) NOT NULL,
    PRIMARY KEY(legajo, id_clase),
    FOREIGN KEY(legajo) REFERENCES Profesional(legajo) ON DELETE CASCADE,
    FOREIGN KEY(id_clase) REFERENCES Clase(id_clase) ON DELETE CASCADE
);

CREATE TABLE Capacitado_para(
    cod_actividad varchar(15) NOT NULL,
    legajo varchar(15) NOT NULL,
    PRIMARY KEY(cod_actividad, legajo),
    FOREIGN KEY(legajo) REFERENCES Profesional(legajo) ON DELETE CASCADE,
    FOREIGN KEY(cod_actividad) REFERENCES Actividad(cod_actividad) ON DELETE CASCADE
);

/* 
 * Seccion de triggers para modelar restricciones
 */

/*
 * Dada una instancia de TITULAR, el valor correspondiente a TITULAR.id_categoria que se iguala con 
 * CATEGORIA.id_categoria, esta instancia de CATEGORÍA, el atributo CATEGORÍA.descripción sólo puede los 
 * valores “mayor” o “vitalicio”.
 */
delimiter $$ 
CREATE TRIGGER titular_categoria 
BEFORE INSERT ON Titular 
FOR EACH ROW 
BEGIN 
    DECLARE dummy varchar(20);
    SELECT
        c.descripcion
    INTO
        dummy
    FROM
        Categoria c
    WHERE
      c.id_categoria = NEW.id_categoria;
    if (dummy <> 'vitalicio') AND (dummy <> 'mayor') then
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No se puede insertar un Titular con una categoría que sea distinta de Mayor o Vitalicio';
    end if;
END $$

/*
 * Creacion del id del familiar cuando se agrega
 */
CREATE TRIGGER familiar_nro_orden 
BEFORE INSERT ON Familiar 
FOR EACH ROW 
BEGIN 
    DECLARE dummy int;
    SELECT
        count(f.nro_orden)
    INTO
        dummy
    FROM
        Familiar f
    WHERE
      f.nro_socio = NEW.nro_socio;
    SET dummy = dummy+1;
    SET NEW.nro_orden = CONCAT('orden', dummy);
END $$

/*
 * ACTIVIDAD.cod_actividad solo puede estar en CLASE.cod_actividad si para la instancia correspondiente 
 * en PUEDE-DESARROLLARSE-EN, dada por la igualdad entre ACTIVIDAD.cod_actididad y ÁREA.cod_area, los 
 * valores de ÁREA.cod_area y CLASE.cod_area son iguales.
 */
delimiter $$ 
CREATE TRIGGER clase_en_area 
BEFORE INSERT ON Clase 
FOR EACH ROW 
BEGIN 
    DECLARE dummy int;
    SELECT
        count(*)
    INTO
        dummy
    FROM
        Clase c, Actividad ac, Puede_Desarrollarse_En pde, Area ar
    WHERE
      c.cod_actividad = ac.cod_actividad AND
      ac.cod_actividad = pde.cod_actividad AND
      pde.cod_area = ar.cod_area AND
      ar.cod_area = c.cod_area;
    if dummy = 0 then
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No puede existir una clase con una actividad que no se pueda desarrollar en ese area';
    end if;
END $$

/*
 * TITULAR.nro_socio sólo puede estar en PAGA_T.nro_socio si para la instancia correspondiente en 
 * SE_INSCRIBE_T, dada por la igualdad entre SE_INSCRIBE_T.id_clase y CLASE.id_clase, y para la instancia 
 * de CLASE, dada por la igualdad entre CLASE.cod_actividad y ACTIVIDAD.cod_actividad, el atributo 
 * ACTIVIDAD.arancelada posee el valor "true"
 */
delimiter $$ 
CREATE TRIGGER titular_paga_clase 
BEFORE INSERT ON Paga_t 
FOR EACH ROW 
BEGIN 
    DECLARE dummy varchar(20);
    SELECT
        count(*)
    INTO
        dummy
    FROM
        Titular t, Se_Inscribe_t st, Clase c, Actividad a
    WHERE
      t.nro_socio = st.nro_socio AND
      st.id_clase = c.id_clase AND
      c.cod_actividad = a.cod_actividad AND
      a.tipo_costo = true;
    if dummy = 0 then
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No puede existir una clase con una actividad que no se pueda desarrollar en ese area';
    end if;
END $$

/*
 * (FAMILIAR.nro_socio, FAMILIAR.nro_orden) sólo puede estar en (PAGA_F.nro_socio, PAGA_F.nro_orden) 
 * si para la instancia correspondiente en SE_INSCRIBE_F, dada por la igualdad entre SE_INSCRIBE_F.id_clase 
 * y CLASE.id_clase, y para la instancia de CLASE, dada por la igualdad entre CLASE.cod_actividad y 
 * ACTIVIDAD.cod_actividad, el atributo ACTIVIDAD.tipo_costo posee el valor “arancelada”
 */

/*
 * Dada una instancia de PROFESIONAL.legajo que está en DIRIGE.legajo y además DIRIGE.id_clase en 
 * CLASE.id_clase, y también una instancia de A-CARGO-DE.legajo igual a PROFESIONAL.legajo, 
 * A-CARGO-DE.cod_actividad debe ser igual a CLASE.cod_actividad
 */

/*
 * El dominio del atributo ACTIVIDAD.tipo_costo solo puede tomar los valores “arancelada” o “gratuita”
 */

/*
 * TITULAR.nro_socio sólo puede estar en SE-INSCRIBE.nro_socio si para la instancia 
 * correspondiente en SE-INSCRIBE, dada por la igualdad entre SE-INSCRIBE.id_clase y CLASE.id_clase, 
 * y para la instancia de CLASE, dada por la igualdad entre CLASE.cod_actividad y ACTIVIDAD.cod_actividad, 
 * TITULAR.id_categoria es igual a ACTIVIDAD.id_categoría
 */

/*
 * (FAMILIAR.nro_socio,FAMILIAR.nro_orden) sólo puede estar en (SE-INSCRIBE.nro_socio, 
 * SE-INSCRIBE.nro_orden) si para la instancia correspondiente en SE-INSCRIBE, dada por la igualdad 
 * entre SE-INSCRIBE.id_clase y CLASE.id_clase, y para la instancia de CLASE, dada por la igualdad entre 
 * CLASE.cod_actividad y ACTIVIDAD.cod_actividad, FAMILIAR.id_categoria es igual a ACTIVIDAD.id_categoría
 */

delimiter ;

/*
 * INSERCIONES
 */
INSERT INTO
    Categoria(id_categoria, descripcion, porcentaje)
VALUES
    ('cat001', 'infantil', '0.15'),
    ('cat002', 'mayor', '0.2'),
    ('cat003', 'vitalicio', '0');

INSERT INTO 
    Titular(
      nro_socio,
      id_categoria,
      nombre,
      apellido,
      fecha_nac,
      email,
      celular,
      telefono,
      domicilio
    )
VALUES
    (
        'soc001', 
        'cat002', 
        'Martin', 
        'Belcic', 
        '1996-11-01', 
        'martin.belcic@gmail.com', 
        '2236888888', 
        '4723339',
        'Alberti 2565'
    );

INSERT INTO 
    Familiar(
      nro_socio,
      id_categoria,
      nombre,
      apellido,
      fecha_nac,
      email,
      celular
    )
VALUES
    (
        'soc001', 
        'cat001', 
        'Martin', 
        'Belcic', 
        '1996-11-01', 
        'martin.belcic@gmail.com', 
        '2236888888'
    );

/* Profesional esta todo mal
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
        '1978-02-10',
        'tenis'
    ),
    (
        '478961',
        'juana',
        'lopez',
        '19589274',
        '1983-06-12',
        'edfisica'
    ),
    (
        '785963',
        'marina',
        'fernandez',
        '35587885',
        '1992-09-16',
        'futbol'
    ),
    (
        '157896',
        'julio',
        'martinez',
        '42558971',
        '1998-08-10',
        'hockey'
    ),
    (
        '478163',
        'guillermina',
        'villa',
        '32589657',
        '1988-05-02',
        'tenis'
    ),
    (
        '147852',
        'fernando',
        'gomez',
        '39174589',
        '1995-02-06',
        'futbol'
    ),
    (
        '454123',
        'mateo',
        'mariani',
        '29885741',
        '1989-03-11',
        'edfisica'
    ),
    (
        '851173',
        'karen',
        'juarez',
        '39887414',
        '1996-12-20',
        'edfisica'
    ),
    (
        '589633',
        'mirta',
        'hernandez',
        '30188941',
        '1985-07-24',
        'natacion'
    ),
    (
        '474583',
        'diego',
        'rios',
        '38182236',
        '1980-10-30',
        'natacion'
    );

______________
INSERT INTO
    Categoria(id_categoria, descripcion, porcentaje)
VALUES
    ('cat001', 'infantil', '0.15'),
    ('cat002', 'mayor', '0.2'),
    ('cat003', 'vitalicio', '0');

#hay que insertar titulares para que se puedan inscribir en una clase
_______________
INSERT INTO
    Se_Inscribe_t(nro_socio, id_clase)
VALUES
    ('soc001', 'cla001'),
    ('soc002', 'cla003'),
    ('soc003', 'cla001'),
    ('soc004', 'cla001'),
    ('soc005', 'cla002'),
    ('soc006', 'cla002'),
    ('soc007', 'cla001'),
    ('soc008', 'cla003'),
    ('soc009', 'cla006'),
    ('soc010', 'cla005'),
    ('soc011', 'cla004'),
    ('soc012', 'cla005');

_______________
INSERT INTO
    Arancelada(cod_actividad, costo, periodo_pago)
VALUES
    ('act005', '800', 'mensual'),
    ('act004', '1500', 'trimestral'),
    ('act007', '650', 'mensual');

_______________
INSERT INTO
    Puede_Desarrollarse_En(cod_actividad, cod_area)
VALUES
    ('act001', 'area001'),
    ('act001', 'area005'),
    ('act002', 'area001'),
    ('act003', 'area001'),
    ('act003', 'area002'),
    ('act004', 'area004'),
    ('act005', 'area003'),
    ('act006','area003'),
    ('act006','area002'),
    ('act007','area006');

________________

INSERT INTO 
    Paga_t(nro_socio,cod_actividad,fecha,monto)
VALUES
    ('soc001','act004','2019-10-20','1500'),
    ('soc001','act005','2018-11-28','800'),
    ('soc002','act004','2018-09-21','1500'),
    ('soc003','act007','2019-10-10','650'),
    ('soc004','act007','2018-08-11','150'),
    ('soc005','act004','2017-07-15','1000'),
    ('soc005','act005','2017-01-31','800')),
    ('soc005','act007','2017-01-30','650'),
    ('soc004','act005','2016-03-02','500')),
    ('soc006','act004','2018-11-07','1500'),
    ('soc006','act007','2019-04-06','600'),
    ('soc007','act005','2019-02-07','800')),
    ('soc008','act004','2019-02-15','700'),
    ('soc009','act004','2017-01-17','1100'),
    ('soc010','act005','2016-10-19','200')),
    ('soc010','act007','2018-08-27','500'),
    ('soc011','act007','2018-08-24','650'),
    ('soc011','act005','2019-09-21','700')),
    ('soc012','act004','2019-04-14','100'),
    ('soc012','act007','2018-06-17','300'),
    ('soc013','act004','2019-07-03','1500');
    
______________

INSERT INTO 
    Paga_f(nro_socio,nro_orden,cod_actividad,fecha,monto)
VALUES
    ('soc001','01','act004','2019-10-20','1500'),
    ('soc001','02','act005','2018-11-28','800'),
    ('soc002','01','act004','2018-09-21','1500'),
    ('soc003','02','act007','2019-10-10','650'),
    ('soc004','03','act007','2018-08-11','150'),
    ('soc005','02','act004','2017-07-15','1000'),
    ('soc005','02','act005','2017-01-31','800')),
    ('soc005','01','act007','2017-01-30','650'),
    ('soc004','03','act005','2016-03-02','500')),
    ('soc006','01','act004','2018-11-07','1500'),
    ('soc006','02','act007','2019-04-06','600'),
    ('soc007','03','act005','2019-02-07','800')),
    ('soc008','01','act004','2019-02-15','700'),
    ('soc009','01','act004','2017-01-17','1100'),
    ('soc010','01','act005','2016-10-19','200')),
    ('soc010','02','act007','2018-08-27','500'),
    ('soc011','01','act007','2018-08-24','650'),
    ('soc011','03','act005','2019-09-21','700')),
    ('soc012','02','act004','2019-04-14','100'),
    ('soc012','04','act007','2018-06-17','300'),
    ('soc013','01','act004','2019-07-03','1500');

_____

delimiter //
CREATE PROCEDURE 'soc_act_gratuitas' (OUT )
    BEGIN
        DECLARE Fecha DATE;
        SELECT CURRENT_DATE() INTO Fecha;
        SELECT id_categoria, COUNT(*)
        FROM Titular, Familiar
        WHERE NOT EXISTS
        (
            SELECT *
            FROM Clase, Actividad
            WHERE Clase.cod_actividad=Actividad.cod_actividad AND NOT EXISTS 

            (
                SELECT *
                FROM Se
            )
        )

//

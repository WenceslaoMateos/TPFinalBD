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
    capacidad int unsigned NOT NULL,
    estado varchar(20),
    PRIMARY KEY(cod_area)
);

#una categoria nula se considera general
CREATE TABLE Actividad(
    cod_actividad varchar(15) NOT NULL,
    descripcion varchar(50),
    nombre varchar(20) NOT NULL,
    arancelada boolean NOT NULL,
    id_categoria varchar(15),
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

#tendriamos que los periodos acorde a que tipo son calcular los valores?
CREATE TABLE Arancelada(
    cod_actividad varchar(15) NOT NULL,
    costo float unsigned NOT NULL,
    periodo_pago varchar(20) NOT NULL,
    PRIMARY KEY(cod_actividad)
);

#tendriamos que los periodos acorde a que tipo son calcular los valores?
CREATE TABLE Cuota(
    id_cuota varchar(15) NOT NULL,
    monto_base float unsigned,
    periodo varchar(20) NOT NULL,
    PRIMARY KEY(id_cuota)
);

CREATE TABLE Pago(
    id_cuota varchar(15) NOT NULL,
    nro_socio varchar(15) NOT NULL,
    nro_pago varchar(15) NOT NULL,
    monto_abonado float unsigned NOT NULL,
    monto_pagar float unsigned NOT NULL,
    fecha_vencimiento date NOT NULL,
    fecha_pago date NOT NULL,
    PRIMARY KEY (nro_socio, nro_pago),
    FOREIGN KEY (id_cuota) REFERENCES Cuota(id_cuota) ON DELETE CASCADE,
    FOREIGN KEY (nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE
);

CREATE TABLE Se_Inscribe_t(
    nro_socio varchar(15) NOT NULL,
    id_clase varchar(15) NOT NULL,
    fecha_inscrip date NOT NULL,
    PRIMARY KEY(nro_socio, id_clase),
    FOREIGN KEY(nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE,
    FOREIGN KEY(id_clase) REFERENCES Clase(id_clase) ON DELETE CASCADE
);

CREATE TABLE Se_Inscribe_f(
    nro_socio varchar(15) NOT NULL,
    nro_orden varchar(15) NOT NULL,
    id_clase varchar(15) NOT NULL,
    fecha_inscrip date NOT NULL,
    PRIMARY KEY(nro_socio, nro_orden, id_clase),
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
    monto float unsigned NOT NULL,
    PRIMARY KEY (nro_socio, id_clase),
    FOREIGN KEY (id_clase) REFERENCES Clase(id_clase) ON DELETE CASCADE,
    FOREIGN KEY (nro_socio) REFERENCES Titular(nro_socio) ON DELETE CASCADE
);

CREATE TABLE Paga_f(
    nro_socio varchar(15) NOT NULL,
    nro_orden varchar(15) NOT NULL,
    id_clase varchar(15) NOT NULL,
    fecha Date NOT NULL,
    monto float unsigned NOT NULL,
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
 * Los titulares deben pertenecer a la categoría “mayores” o “vitalicios”.
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
 * Creacion del nro de orden del familiar cuando se agrega
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
    SET dummy = dummy + 1;
    SET NEW.nro_orden = CONCAT('orden', dummy);
END $$

/*
 * Creacion del numero de pago cuando se agrega
 */
CREATE TRIGGER nuevo_pago 
BEFORE INSERT ON Pago 
FOR EACH ROW 
BEGIN 
    DECLARE dummy int;
    SELECT
        count(p.nro_pago)
    INTO
        dummy
    FROM
        Pago p
    WHERE
        p.id_cuota = NEW.id_cuota;
    SET dummy = dummy + 1;
    SET NEW.nro_pago = CONCAT('pago', dummy);
END $$

/*
 * La actividad que se realiza en una clase, debe poder desarrollarse en el área asignada a dicha clase.
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
        Actividad ac, Puede_Desarrollarse_En pde, Area ar
    WHERE
        NEW.cod_actividad = ac.cod_actividad AND
        ac.cod_actividad = pde.cod_actividad AND
        pde.cod_area = ar.cod_area AND
        ar.cod_area = NEW.cod_area;
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No puede existir una clase con una actividad que no se pueda desarrollar en ese area';
    end if;
END $$

/*
 * Los titulares sólo pagan clases correspondientes a actividades aranceladas.
 */
delimiter $$ 
CREATE TRIGGER titular_paga_clase 
BEFORE INSERT ON Paga_t 
FOR EACH ROW 
BEGIN 
    DECLARE dummy int;
    SELECT
        count(*)
    INTO
        dummy
    FROM
        Se_Inscribe_t st, Clase c, Actividad a
    WHERE
        NEW.nro_socio = st.nro_socio AND
        st.id_clase = c.id_clase AND
        c.cod_actividad = a.cod_actividad AND
        a.arancelada = true;
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un titular no puede pagar una clase que no sea arancelada';
    end if;
END $$

/*
 * Los familiares sólo pagan clases correspondientes a actividades aranceladas.
 */
delimiter $$ 
CREATE TRIGGER familiar_paga_clase 
BEFORE INSERT ON Paga_f
FOR EACH ROW 
BEGIN 
    DECLARE dummy int;
    SELECT
        count(*)
    INTO
        dummy
    FROM
        Se_Inscribe_f sf, Clase c, Actividad a
    WHERE
        NEW.nro_socio = sf.nro_socio AND
        NEW.nro_orden = sf.nro_orden AND
        sf.id_clase = c.id_clase AND
        c.cod_actividad = a.cod_actividad AND
        a.arancelada = true;
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un familiar no puede pagar una clase que no sea arancelada';
    end if;
END $$

/*
 * Los profesionales que dirigen una clase, deben estar capacitados para la actividad 
 * correspondiente a la clase.
 */
delimiter $$ 
CREATE TRIGGER profesional_dirige_clase 
BEFORE INSERT ON Dirige
FOR EACH ROW 
BEGIN 
    DECLARE dummy int;
    SELECT
        count(*)
    INTO
        dummy
    FROM
        Clase c, Capacitado_para cp
    WHERE
        NEW.id_clase = c.id_clase AND
        c.cod_actividad = cp.cod_actividad AND
        cp.legajo = NEW.legajo;
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un profesional solo puede dirigir clases para las que esta capacitado';
    end if;
END $$

/*
 * Los titulares sólo se pueden inscribir a clases asociadas a actividades que coincidan 
 * con la categoría a la que pertenece.
 */
delimiter $$ 
CREATE TRIGGER titular_se_inscribe 
BEFORE INSERT ON Se_Inscribe_t
FOR EACH ROW 
BEGIN 
    DECLARE dummy int;
    SELECT
        count(*)
    INTO
        dummy
    FROM
        Titular t, Clase c, Actividad a
    WHERE
        NEW.nro_socio = t.nro_socio AND
        (t.id_categoria = a.id_categoria OR a.id_categoria = NULL) AND
        a.cod_actividad = c.cod_actividad AND
        c.id_clase = NEW.id_clase;
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un titular solo se puede inscribir a una actividad dentro de su categoria';
    end if;
END $$

/*
 * Los familiares sólo se pueden inscribir a clases asociadas a actividades que coincidan con la 
 * categoría a la que pertenece.
 */
delimiter $$ 
CREATE TRIGGER familiar_se_inscribe 
BEFORE INSERT ON Se_Inscribe_f
FOR EACH ROW 
BEGIN 
    DECLARE dummy int;
    SELECT
        count(*)
    INTO
        dummy
    FROM
        Familiar f, Clase c, Actividad a
    WHERE
        NEW.nro_socio = f.nro_socio AND
        NEW.nro_orden = f.nro_orden AND
        (t.id_categoria = a.id_categoria OR a.id_categoria = NULL) AND
        a.cod_actividad = c.cod_actividad AND
        c.id_clase = NEW.id_clase;
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un familiar solo se puede inscribir a una actividad dentro de su categoria';
    end if;
END $$

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
    Titular(nro_socio, id_categoria, nombre, apellido, fecha_nac, email, celular, telefono, domicilio)
VALUES
    ('soc001', 'cat002', 'Martin','Belcic','1996-11-01','martin.belcic@gmail.com','2236888888','4723339','Alberti 2565'),
    ('soc002', 'cat003', 'Martina','Alcalde','1996-06-05','martinaalc@gmail.com','2235808313','4653831','Roca 671'),
    ('soc003', 'cat003', 'Susana','Vega','1975-11-15','holasusana@gmail.com','2234999555','4787952','Rivas 4019'),
    ('soc004', 'cat002', 'Eugenia','Flores','1989-02-26','floreeuge@gmail.com','2235424143','4512968','San Lorenzo 1549'),
    ('soc005', 'cat002', 'Franco','Rosso','1986-01-01','francorosso@gmail.com','2236889898','4942536','San Luis 689'),
    ('soc006', 'cat003', 'Juan Ignacio','Aguila','1993-12-08','juanignacioaguila@gmail.com','2234512152','4724745','Almafuerte 1770'),
    ('soc007', 'cat003', 'Julio','Ely','1990-05-05','julioely@gmail.com','2235232629','4642128','Tres Arroyos 2820'),
    ('soc008', 'cat002', 'Fatima','Carreras','1996-09-01','faticarreras@gmail.com','2234789632','4642055','Avellaneda 652'),
    ('soc009', 'cat003', 'Manuela','Onofri','1997-08-06','manuelaonofri@gmail.com','2235252526','4789632','Alberti 1485'),
    ('soc010', 'cat002', 'Blas','Lopez','1980-02-18','elblas@gmail.com','2235484523','4512326','Junin 3698'),
    ('soc011', 'cat002', 'Rosario','Iturria','1966-07-17','rositurria@gmail.com','2236787796','4518982','San Juan 4000'),
    ('soc012', 'cat003', 'Hugo','Ferraris','1968-05-10','hugoferraris@gmail.com','2236124569','4511826','Peña 265'),
    ('soc013', 'cat002', 'Marcos','Piña','1996-03-14','marcospiña@gmail.com','2236789632','4547879','Genova 2590');

INSERT INTO Familiar(nro_socio, id_categoria,nombre,apellido,fecha_nac,email,celular)
VALUES
    ('soc001', 'cat002', 'Trinidad', 'Buenaventura', '1982-06-30', 'tri.buena@gmail.com', '2230392014'),
    ('soc002', 'cat002', 'Amado', 'Benigno', '1977-03-28', 'Amado77Benigno@hotmail.com', '2235659297'),
    ('soc003', 'cat001', 'Bernabe', 'Gutierre', '2005-12-12', 'bernigutierre@gmail.com', '2237905215'),
    ('soc004', 'cat001', 'Carla', 'Vito', '2008-05-04', 'carlavito08@hotmail.com', '2230832559'),
    ('soc004', 'cat001', 'Emiliano', 'Alfredo', '2002-10-06', 'emialfred2@gmail.com', '2234064671'),
    ('soc005', 'cat002', 'Federico', 'Hugo', '1943-01-20', 'hugofederico@hotmail.com', '2235718125'),
    ('soc005', 'cat002', 'Angela', 'Rosalinda', '1960-11-21', 'angelarosalinda1960@gmail.com', '2239403084'),
    ('soc005', 'cat002', 'Rogelio', 'Mireia', '1932-01-13', 'mirerogelio32@hotmail.com', '2232229909'),
    ('soc006', 'cat002', 'Marita', 'Ariel', '1946-05-20', 'maritariel.46@gmail.com', '2235023156'),
    ('soc006', 'cat002', 'Clarissa', 'Modesta', '1970-03-11', 'clarimodesta1970@hotmail.com', '2238045242'),
    ('soc007', 'cat002', 'Jose', 'Xochitl', '1983-10-25', 'josexochi83@hotmail.com', '2237334903'),
    ('soc008', 'cat001', 'Luz', 'Alfredo', '2014-02-20', 'lualfredo@hotmail.com', '2239592945'),
    ('soc009', 'cat002', 'Pilar', 'Reyes', '1964-02-18', 'pilireyesc@gmail.com', '2238512564'),
    ('soc010', 'cat002', 'Maria', 'Natalia', '1943-11-14', 'fati1943nat@hotmail.com', '2234345698'),
    ('soc010', 'cat002', 'Aaron', 'Fidel', '1984-03-23', 'aaronfi84@hotmail.com', '2236730748'),
    ('soc011', 'cat002', 'Samuel', 'Lucía', '1991-01-29', 'samuellucia@gmail.com', '2235726272'),
    ('soc011', 'cat002', 'Melisa', 'Soledad', '1968-02-11', 'melisasole68@hotmail.com', '2230195125'),
    ('soc012', 'cat001', 'Oscar', 'Vasco', '2011-04-30', 'oscivasco11@gmail.com', '2237898469'),
    ('soc012', 'cat001', 'Oscar', 'De Niro', '2000-12-21', 'oacarDeNir00@hotmail.com', '2238681295'),
    ('soc013', 'cat001', 'Emiliano', 'Constanza', '2005-03-12', 'emilconstanza05@gmail.com', '2236915380');

INSERT INTO
    Profesional(legajo, nombre, apellido, dni, fecha_nac, especializacion)
VALUES
    ('prof454553','Matias','Suarez','16589236','1978-02-10','tenis'),
    ('prof478961','Juana','Lopez','19589274','1983-06-12','edfisica'),
    ('prof785963','Marina','Fernandez','35587885','1992-09-16','futbol'),
    ('prof157896','Julio','Martinez','42558971','1998-08-10','hockey'),
    ('prof478163','Guillermina','Villa','32589657','1988-05-02','tenis'),
    ('prof147852','Fernando','Gomez','39174589','1995-02-06','futbol'),
    ('prof454123','Mateo','Mariani','29885741','1989-03-11','edfisica'),
    ('prof851173','Karen','Juarez','39887414','1996-12-20','edfisica'),
    ('prof589633','Mirta','Hernandez','30188941','1985-07-24','natacion'),
    ('prof474583','Diego','Rios','38182236','1980-10-30','natacion');

/*
#hay que insertar titulares para que se puedan inscribir en una clase
INSERT INTO
    Se_Inscribe_t(nro_socio, id_clase,fecha_inscrip)
VALUES
    ('soc001', 'cla001','2019-10-10'),
    ('soc002', 'cla003','2018-12-12'),
    ('soc003', 'cla001','2019-11-01'),
    ('soc004', 'cla001','2019-06-01'),
    ('soc005', 'cla002','2019-01-02'),
    ('soc006', 'cla002','2019-07-01'),
    ('soc007', 'cla001','2018-06-03'),
    ('soc008', 'cla003','2018-11-02'),
    ('soc009', 'cla006','2019-05-15'),
    ('soc010', 'cla005','2017-01-02'),
    ('soc011', 'cla004','2018-04-05'),
    ('soc012', 'cla005','2019-01-04');
*/

/*
INSERT INTO
    Puede_Desarrollarse_En(cod_actividad, cod_area)
VALUES
    ('act001', 'area001'),
    ('act001', 'area005'),
    ('act002', 'area001'),
    ('act003', 'area002'),
    ('act004', 'area004'),
    ('act005', 'area003'),
    ('act006', 'area006'),
    ('act007', 'area003');*/

/*esta mal, paga_t no referencia a cod_actividad, referencia a una clse
INSERT INTO 
  Paga_t(nro_socio, cod_actividad, fecha, monto)
VALUES
    ('soc001', 'act004', '2019-10-20', '1500'),
    ('soc001', 'act005', '2018-11-28', '800'),
    ('soc002', 'act004', '2018-09-21', '1500'),
    ('soc003', 'act007', '2019-10-10', '650'),
    ('soc004', 'act007', '2018-08-11', '150'),
    ('soc005', 'act004', '2017-07-15', '1000'),
    ('soc005', 'act005', '2017-01-31', '800'),
    ('soc005', 'act007', '2017-01-30', '650'),
    ('soc004', 'act005', '2016-03-02', '500'),
    ('soc006', 'act004', '2018-11-07', '1500'),
    ('soc006', 'act007', '2019-04-06', '600'),
    ('soc007', 'act005', '2019-02-07', '800'),
    ('soc008', 'act004', '2019-02-15', '700'),
    ('soc009', 'act004', '2017-01-17', '1100'),
    ('soc010', 'act005', '2016-10-19', '200'),
    ('soc010', 'act007', '2018-08-27', '500'),
    ('soc011', 'act007', '2018-08-24', '650'),
    ('soc011', 'act005', '2019-09-21', '700'),
    ('soc012', 'act004', '2019-04-14', '100'),
    ('soc012', 'act007', '2018-06-17', '300'),
    ('soc013', 'act004', '2019-07-03', '1500');*/
    
    /*
INSERT INTO 
  Paga_f(nro_socio, nro_orden, cod_actividad, fecha, monto)
VALUES
    ('soc001', 'orden1', 'act004', '2019-10-20', '1500'),
    ('soc001', 'orden2', 'act005', '2018-11-28', '800'),
    ('soc002', 'orden1', 'act004', '2018-09-21', '1500'),
    ('soc003', 'orden2', 'act007', '2019-10-10', '650'),
    ('soc004', 'orden3', 'act007', '2018-08-11', '150'),
    ('soc005', 'orden2', 'act004', '2017-07-15', '1000'),
    ('soc005', 'orden2', 'act005', '2017-01-31', '800'),
    ('soc005', 'orden1', 'act007', '2017-01-30', '650'),
    ('soc004', 'orden3', 'act005', '2016-03-02', '500'),
    ('soc006', 'orden1', 'act004', '2018-11-07', '1500'),
    ('soc006', 'orden2', 'act007', '2019-04-06', '600'),
    ('soc007', 'orden3', 'act005', '2019-02-07', '800'),
    ('soc008', 'orden1', 'act004', '2019-02-15', '700'),
    ('soc009', 'orden1', 'act004', '2017-01-17', '1100'),
    ('soc010', 'orden1', 'act005', '2016-10-19', '200'),
    ('soc010', 'orden2', 'act007', '2018-08-27', '500'),
    ('soc011', 'orden1', 'act007', '2018-08-24', '650'),
    ('soc011', 'orden3', 'act005', '2019-09-21', '700'),
    ('soc012', 'orden2', 'act004', '2019-04-14', '100'),
    ('soc012', 'orden4', 'act007', '2018-06-17', '300'),
    ('soc013', 'orden1', 'act004', '2019-07-03', '1500');*/

INSERT INTO 
    Area(cod_area, ubicacion, capacidad, estado)
VALUES 
    ('area006', 'cancha_de_tenis', '20', 'apta'),
    ('area002', 'pileta', '40', 'apta'),
    ('area003', 'cancha_de_hockey', '40', 'apta'),
    ('area004', 'cancha_de_futbol', '40', 'apta'),
    ('area005', 'gimnasio_1', '60', 'apta'),
    ('area001', 'gimnasio_2', '40', 'en_reparacion');

# 4,5 y 7 aranceladas
INSERT INTO
    Actividad(cod_actividad, descripcion, nombre, arancelada, id_categoria)
VALUES 
    ('act001', 'clase_de_gimnasia_integral', 'gimnasia', false, NULL),
    ('act002', 'clase_de_edfisica_infantil', 'ed_fisica', false, 'cat001'),
    ('act003', 'clase_de_pileta_infantil', 'pileta_infantil', false, 'cat001'),
    ('act004', 'futbol_integral', 'futbol', true, NULL),
    ('act005', 'hockey_femenino_integral', 'hockey_femenino', true, NULL),
    ('act006', 'tenis_integral', 'tenis', false, NULL),
    ('act007', 'hockey_masculino_integral', 'hockey_masculino', true, NULL);

delimiter //
CREATE PROCEDURE 'soc_act_gratuitas' ()
    BEGIN
        DECLARE Fecha DATE;
        SELECT CURRENT_DATE() INTO fechaAux;
        
        SELECT id_categoria, SUM(cant)
        FROM
        (
            /* cant titutales por categoria */
            SELECT t.id_categoria, COUNT(*) AS cant
            FROM Titular t
            WHERE NOT EXISTS
            (
                SELECT *
                FROM Clase c, Actividad a
                WHERE YEAR(a.fecha_inscrip)=YEAR(fechaAUX) AND (a.id_categoria=t.id_categoria OR a.id_categoria=NULL) AND c.cod_actividad=a.cod_actividad AND
                NOT EXISTS
                (
                    SELECT *
                    FROM Se_Inscribe_t st
                    WHERE st.nro_socio=t.nro_socio AND st.id_clase=c.id_clase
                )
            )
            GROUP BY id_categoria

            union all

            /* cant socios por categoria */
            SELECT f.id_categoria, COUNT(*) AS cant
            FROM Familiar f
            WHERE NOT EXISTS
            (
                SELECT *
                FROM Clase c, Actividad a
                WHERE YEAR(a.fecha_inscrip)=YEAR(fechaAUX) AND (a.id_categoria=f.id_categoria OR a.id_categoria=NULL) AND c.cod_actividad=a.cod_actividad AND
                NOT EXISTS
                (
                    SELECT *
                    FROM Se_Inscribe_f sf
                    WHERE sf.nro_socio=f.nro_socio AND sf.nro_orden=f.nro_orden AND sf.id_clase=c.id_clase
                )
            )
            GROUP BY id_categoria
        )
        GROUP BY id_categoria;
    END
//

delimiter ;

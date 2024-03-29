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
    dia char(9) NOT NULL,
    hora char(5) NOT NULL,
    duracion int unsigned NOT NULL,
    cod_actividad varchar(15) NOT NULL,
    cod_area varchar(15) NOT NULL,
    periodo varchar(20),
    PRIMARY KEY(id_clase),
    FOREIGN KEY(cod_actividad) REFERENCES Actividad(cod_actividad) ON DELETE CASCADE,
    FOREIGN KEY(cod_area) REFERENCES Area(cod_area) ON DELETE CASCADE
);

CREATE TABLE Arancelada(
    cod_actividad varchar(15) NOT NULL,
    costo float unsigned NOT NULL,
    periodo_pago varchar(20) NOT NULL,
    PRIMARY KEY(cod_actividad),
    FOREIGN KEY(cod_actividad) REFERENCES Actividad(cod_actividad) ON DELETE CASCADE
);

CREATE TABLE Cuota(
    id_cuota varchar(15) NOT NULL,
    monto_base float unsigned NOT NULL,
    periodo varchar(20) NOT NULL,
    fecha_cuota date NOT NULL,
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
    PRIMARY KEY (nro_socio, nro_pago, id_cuota),
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
 * Los profesionales no pueden dirigir mas de una clase el mismo dia a la misma hora.
 */
delimiter $$ 
CREATE TRIGGER profesional_dirige_unica_clase
BEFORE INSERT ON Dirige 
FOR EACH ROW 
BEGIN 
    DECLARE dummy int;
    SELECT
        count(hora)
    INTO
        dummy
    FROM
        Dirige d, Clase c
    WHERE
        NEW.legajo = d.legajo AND
        d.id_clase = c.id_clase
    GROUP BY 
        c.dia, c.hora;
    if dummy > 1 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede asignar un Profesional a una clase, si este ya dirige otra clase en el mismo dia y horario';
    end if;
END $$

/*
 * Los titulares deben pertenecer a la categoría “mayores” o “vitalicios”.
 */
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
 * Actividad solo puede ser arancelada si el boolean de arancelada es true
 */
CREATE TRIGGER arancelada_en_actividad 
BEFORE INSERT ON Arancelada 
FOR EACH ROW 
BEGIN 
    DECLARE dummy int;
    SELECT
        count(a.descripcion)
    INTO
        dummy
    FROM
        Actividad a
    WHERE
        a.cod_actividad = NEW.cod_actividad AND
        a.arancelada IS TRUE;
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Una arancelada no puede existir si su actividad no es arancelada';
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
    SET NEW.nro_orden = dummy;
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
 * Tambien verifica que no existan dos clases simultaneas
 */
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
    SELECT
        count(*)
    INTO
        dummy
    FROM
        Actividad ac, Area ar, Clase c
    WHERE
        NEW.dia = c.dia AND
        NEW.hora = c.hora AND
        NEW.cod_area = c.cod_area;
    if dummy > 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pueden superponer dos clases distintas en el mismo area';
    end if;    
END $$

/*
 * Los titulares sólo pagan clases correspondientes a actividades aranceladas.
 */
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
        NEW.id_clase = c.id_clase AND
        c.cod_actividad = a.cod_actividad AND
        a.arancelada;
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un titular no puede pagar una clase que no sea arancelada';
    end if;
END $$

/*
 * Los familiares sólo pagan clases correspondientes a actividades aranceladas.
 */
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
        Se_Inscribe_f sf, Clase c, Actividad a, Familiar f
    WHERE
        NEW.id_clase = c.id_clase AND
        c.cod_actividad = a.cod_actividad AND
        NEW.nro_socio = f.nro_socio AND
        NEW.nro_orden = f.nro_orden AND
        (a.id_categoria IS NULL OR f.id_categoria = a.id_categoria);
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un titular solo se puede inscribir a una actividad general o dentro de su categoria';
    end if;
END $$

/*
 * Los profesionales que dirigen una clase, deben estar capacitados para la actividad 
 * correspondiente a la clase.
 */
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
        (t.id_categoria = a.id_categoria OR a.id_categoria IS NULL) AND
        a.cod_actividad = c.cod_actividad AND
        c.id_clase = NEW.id_clase;
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un titular solo se puede inscribir a una actividad general o dentro de su categoria';
    end if;
END $$

/*
 * Los familiares sólo se pueden inscribir a clases asociadas a actividades que coincidan con la 
 * categoría a la que pertenece.
 */
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
        NEW.id_clase = c.id_clase AND
        c.cod_actividad = a.cod_actividad AND
        (a.id_categoria IS NULL OR f.id_categoria = a.id_categoria);
    if dummy = 0 then
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un familiar solo se puede inscribir a una actividad general o dentro de su categoria';
    end if;
END $$

delimiter ;

/*
 * INSERCIONES
 */
INSERT INTO
    Categoria(id_categoria, descripcion, porcentaje)
VALUES
    ('cat001', 'infantil', -30),
    ('cat002', 'mayor', 3),
    ('cat003', 'vitalicio', -100);

INSERT INTO 
    Titular(nro_socio, id_categoria, nombre, apellido, fecha_nac, email, celular, telefono, domicilio)
VALUES
    ('soc001', 'cat002', 'Martin', 'Belcic', '1996-11-01', 'martin.belcic@gmail.com', '2236888888', '4723339', 'Alberti 2565'),
    ('soc002', 'cat003', 'Martina', 'Alcalde', '1996-06-05', 'martinaalc@gmail.com', '2235808313', '4653831', 'Roca 671'),
    ('soc003', 'cat003', 'Susana', 'Vega', '1975-11-15', 'holasusana@gmail.com', '2234999555', '4787952', 'Rivas 4019'),
    ('soc004', 'cat002', 'Eugenia', 'Flores', '1989-02-26', 'floreeuge@gmail.com', '2235424143', '4512968', 'San Lorenzo 1549'),
    ('soc005', 'cat002', 'Franco', 'Rosso', '1986-01-01', 'francorosso@gmail.com', '2236889898', '4942536', 'San Luis 689'),
    ('soc006', 'cat003', 'Juan Ignacio', 'Aguila', '1993-12-08', 'juanignacioaguila@gmail.com', '2234512152', '4724745', 'Almafuerte 1770'),
    ('soc007', 'cat003', 'Julio', 'Ely', '1990-05-05', 'julioely@gmail.com', '2235232629', '4642128', 'Tres Arroyos 2820'),
    ('soc008', 'cat002', 'Fatima', 'Carreras', '1996-09-01', 'faticarreras@gmail.com', '2234789632', '4642055', 'Avellaneda 652'),
    ('soc009', 'cat003', 'Manuela', 'Onofri', '1997-08-06', 'manuelaonofri@gmail.com', '2235252526', '4789632', 'Alberti 1485'),
    ('soc010', 'cat002', 'Blas', 'Lopez', '1980-02-18', 'elblas@gmail.com', '2235484523', '4512326', 'Junin 3698'),
    ('soc011', 'cat002', 'Rosario', 'Iturria', '1966-07-17', 'rositurria@gmail.com', '2236787796', '4518982', 'San Juan 4000'),
    ('soc012', 'cat003', 'Hugo', 'Ferraris', '1968-05-10', 'hugoferraris@gmail.com', '2236124569', '4511826', 'Peña 265'),
    ('soc013', 'cat002', 'Marcos', 'Piña', '1996-03-14', 'marcospiña@gmail.com', '2236789632', '4547879', 'Genova 2590');

INSERT INTO 
    Familiar(nro_socio, id_categoria,nombre,apellido,fecha_nac,email,celular)
VALUES  
    ('soc001', 'cat001', 'Trinidad', 'Buenaventura', '2005-06-30', 'tri.buena@gmail.com', '2230392014'),
    ('soc001', 'cat002', 'Ximena', 'Belcic', '1987-03-23', 'ximeDarl@gmail.com', '2230345201'),
    ('soc002', 'cat002', 'Amado', 'Alcalde', '1977-03-28', 'Amado77Benigno@hotmail.com', '2235659297'),
    ('soc003', 'cat001', 'Esteban', 'Vega', '2000-07-12', 'estebangutierre@hotmail.com', '2237905215'),
    ('soc003', 'cat001', 'Bernabe', 'Vega', '2005-12-12', 'bernigutierre@gmail.com', '2237905215'),
    ('soc003', 'cat001', 'Amelia', 'Vega', '2005-07-20', 'mercyame@gmail.com', '2237937215'),
    ('soc003', 'cat001', 'Natalia', 'Vega', '2008-03-12', 'natinelida@gmail.com', '2237994915'),
    ('soc004', 'cat001', 'Carla', 'Flores', '2008-05-04', 'carlavito08@hotmail.com', '2230832559'),
    ('soc004', 'cat001', 'Emiliano', 'Flores', '2002-10-06', 'emialfred2@gmail.com', '2234064671'),
    ('soc004', 'cat002', 'Víctor', 'Brannon', '1999-09-09', 'vicbrannon@gmail.com', '2234064671'),
    ('soc004', 'cat002', 'Fermín', 'Flores', '1987-04-11', 'ferminalf2@gmail.com', '2234002871'),
    ('soc005', 'cat002', 'Federico', 'Rosso', '1943-01-20', 'hugofederico@hotmail.com', '2235718125'),
    ('soc005', 'cat001', 'Angela', 'Rosalinda', '2006-11-21', 'angelarosalinda1960@gmail.com', '2239403084'),
    ('soc005', 'cat001', 'Rogelio', 'Rosso', '2010-01-13', 'mirerogelio32@hotmail.com', '2232229909'),
    ('soc006', 'cat002', 'Marita', 'Ariel', '1946-05-20', 'maritariel.46@gmail.com', '2235023156'),
    ('soc006', 'cat002', 'Aguila', 'Modesta', '1970-03-11', 'clarimodesta1970@hotmail.com', '2238045242'),
    ('soc007', 'cat001', 'Jose', 'Ely', '2003-10-25', 'josexochi83@hotmail.com', '2237334903'),
    ('soc007', 'cat002', 'Francisco', 'Ely', '1989-11-13', 'francishaz@hotmail.com', '2239524903'),
    ('soc007', 'cat002', 'Candelaria', 'Ely', '1992-05-18', 'candemarlin92@hotmail.com', '2237062903'),
    ('soc008', 'cat001', 'Luz', 'Carreras', '2014-02-20', 'lualfredo@hotmail.com', '2239592945'),
    ('soc008', 'cat001', 'Alan', 'Carreras', '2003-04-18', 'alanlill03@hotmail.com', '2239590385'),
    ('soc009', 'cat001', 'Pilar', 'Onofri', '2001-02-18', 'pilireyesc@gmail.com', '2238512564'),
    ('soc009', 'cat001', 'Owen', 'Onofri', '2003-03-27', 'owenvirgi92@gmail.com', '2238529364'),
    ('soc010', 'cat002', 'Maria', 'Lopez', '1943-11-14', 'fati1943nat@hotmail.com', '2234345698'),
    ('soc010', 'cat002', 'Aaron', 'Fidel', '1984-03-23', 'aaronfi84@hotmail.com', '2236730748'),
    ('soc011', 'cat002', 'Samuel', 'Iturria', '1991-01-29', 'samuellucia@gmail.com', '2235726272'),
    ('soc011', 'cat002', 'Hernan', 'Iturria', '1994-05-20', 'hermanwil@gmail.com', '2235726272'),
    ('soc011', 'cat001', 'Lucas', 'Iturria', '2004-05-20', 'lucas04wilfredo@gmail.com', '2235720252'),
    ('soc011', 'cat002', 'Melisa', 'Soledad', '1968-02-11', 'melisasole68@hotmail.com', '2230195125'),
    ('soc012', 'cat001', 'Oscar', 'Ferraris', '2002-07-17', 'oacarDeNir00@hotmail.com', '2238681295'),
    ('soc012', 'cat001', 'Valentina', 'Ferraris', '2011-04-30', 'valenr@gmail.com', '2237937469'),
    ('soc012', 'cat001', 'Oscar', 'Ferraris', '2009-03-27', 'oscivasco11@gmail.com', '2237898469'),
    ('soc012', 'cat002', 'Lujan', 'Vasco', '1989-06-19', 'luvasco@gmail.com', '2237802669'),
    ('soc012', 'cat001', 'Ramiro', 'Vasco', '2005-12-21', 'ramaDeNir00@hotmail.com', '2238039295'),
    ('soc013', 'cat001', 'Emiliano', 'Piña', '2005-03-12', 'emilmortimer05@gmail.com', '2236915380'),
    ('soc013', 'cat001', 'Juan', 'Piña', '2006-09-12', 'mortijuan1998@gmail.com', '2236029380');

INSERT INTO
    Profesional(legajo, nombre, apellido, dni, fecha_nac, especializacion)
VALUES
    ('454553', 'Matias', 'Suarez', '16589236', '1978-02-10', 'tenis'),
    ('478961', 'Juana', 'Lopez', '19589274', '1983-06-12', 'edfisica'),
    ('785963', 'Marina', 'Fernandez', '35587885', '1992-09-16', 'futbol'),
    ('157896', 'Julio', 'Martinez', '42558971', '1998-08-10', 'hockey'),
    ('478163', 'Guillermina', 'Villa', '32589657', '1988-05-02', 'tenis'),
    ('147852', 'Fernando', 'Gomez', '39174589', '1995-02-06', 'futbol'),
    ('454123', 'Mateo', 'Mariani', '29885741', '1989-03-11', 'edfisica'),
    ('851173', 'Karen', 'Juarez', '39887414', '1996-12-20', 'edfisica'),
    ('589633', 'Mirta', 'Hernandez', '30188941', '1985-07-24', 'natacion'),
    ('474583', 'Diego', 'Rios', '38182236', '1980-10-30', 'natacion'),
    ('569876', 'Cesar', 'Colavolpe', '39101290', '1994-10-30', 'voley');

INSERT INTO 
    Area(cod_area, ubicacion, capacidad, estado)
VALUES 
    ('area006', 'cancha_de_tenis', '20', 'apta'),
    ('area002', 'pileta', '40', 'apta'),
    ('area003', 'cancha_de_hockey', '40', 'apta'),
    ('area004', 'cancha_de_futbol', '40', 'apta'),
    ('area005', 'gimnasio_1', '60', 'apta'),
    ('area001', 'gimnasio_2', '40', 'en_reparacion'),
    ('area007', 'cancha_de_voley', '27', 'apta');

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
    ('act007', 'hockey_masculino_integral', 'hockey_masculino', true, NULL),
    ('act008', 'voley', 'voley_masculino', false, 'cat003'),
    ('act009', 'clase_de_pileta_vitalicios', 'pileta_vitalicio', false, 'cat003'),
    ('act010','futbol_adultos_exclusivo','futbol',false,'cat002');

INSERT INTO
    Puede_Desarrollarse_En(cod_actividad, cod_area)
VALUES
    ('act001', 'area001'),
    ('act001', 'area005'),
    ('act002', 'area001'),
    ('act002', 'area005'),
    ('act003', 'area002'),
    ('act004', 'area004'),
    ('act005', 'area003'),
    ('act006', 'area006'),
    ('act007', 'area003'),
    ('act008', 'area007'),
    ('act009', 'area002'),
    ('act010', 'area004');
INSERT INTO 
    Clase(id_clase, dia, hora, duracion, cod_actividad, cod_area, periodo)
VALUES
    ('cla001', 'martes', '18:00',120, 'act001', 'area005', 'tarde'),
    ('cla002', 'jueves', '18:00',120, 'act002', 'area005', 'tarde'),
    ('cla003', 'lunes', '18:00',120, 'act003', 'area002', 'tarde'),
    ('cla004', 'miercoles', '20:00',120, 'act004', 'area004', 'tarde'),
    ('cla005', 'viernes', '18:00',120, 'act005', 'area003' , 'tarde'), 
    ('cla006', 'lunes', '16:00',60, 'act006', 'area006', 'tarde'),
    ('cla007', 'jueves', '16:00',60, 'act001', 'area005', 'tarde'),
    ('cla008', 'martes', '14:00',120, 'act010', 'area004', 'tarde'),
    ('cla009', 'jueves', '14:00',120, 'act003', 'area002', 'tarde'),
    ('cla010','viernes','18:30',90,'act008','area007','tarde'),
    ('cla011','sabado','20:00',60,'act009','area002','tarde');
  
INSERT INTO
    Arancelada(cod_actividad, costo, periodo_pago)
VALUES 
    ('act004', 1500.0, 'trimestral'),
    ('act005', 800.0, 'mensual'),
    ('act007', 650.0, 'mensual');

INSERT INTO
    Capacitado_para(cod_actividad, legajo)
VALUES
    ('act001', '478961'),
    ('act002', '478961'),
    ('act001', '454123'),
    ('act002', '454123'),
    ('act001', '851173'),
    ('act002', '851173'),
    ('act003', '589633'),
    ('act003', '474583'),
    ('act004', '147852'),
    ('act004', '785963'),
    ('act005', '157896'),
    ('act006', '454553'),
    ('act006', '478163'),
    ('act007', '157896'),
    ('act008', '569876'),
    ('act009', '474583'),
    ('act009', '589633'),
    ('act010', '147852'),
    ('act010', '785963');

INSERT INTO
    Dirige(legajo, id_clase)
VALUES
    ('478961', 'cla001'),
    ('454123', 'cla002'),
    ('589633', 'cla003'),
    ('785963', 'cla004'),
    ('157896', 'cla005'),
    ('478163', 'cla006'),
    ('478961', 'cla007'),
    ('147852', 'cla008'),
    ('589633', 'cla009'),
    ('569876', 'cla010'),
    ('474583', 'cla011');


INSERT INTO
    Se_Inscribe_t(nro_socio, id_clase, fecha_inscrip)
VALUES
    ('soc001', 'cla001', '2018-10-10'), 
    ('soc001', 'cla007', '2018-10-10'),
    ('soc001', 'cla008', '2018-10-10'),
    ('soc001', 'cla004', '2018-10-10'),
    ('soc001', 'cla006', '2018-10-10'),
    ('soc002', 'cla006', '2018-12-12'),
    ('soc002', 'cla005', '2018-12-12'),
    ('soc003', 'cla001', '2018-11-01'),
    ('soc003', 'cla011', '2018-11-01'),
    ('soc003', 'cla007', '2018-11-01'),
    ('soc003', 'cla006', '2018-11-01'),
    ('soc003', 'cla010', '2018-11-01'),
    ('soc003', 'cla004', '2018-11-01'),
    ('soc003', 'cla005', '2018-11-01'),
    ('soc004', 'cla006', '2019-06-01'),
    ('soc005', 'cla008', '2019-01-02'),
    ('soc006', 'cla007', '2019-07-01'),
    ('soc006', 'cla010', '2019-07-01'),
    ('soc006', 'cla011', '2019-07-01'),
    ('soc007', 'cla007', '2018-06-03'),
    ('soc008', 'cla001', '2018-11-02'),
    ('soc009', 'cla006', '2019-05-15'),
    ('soc009', 'cla011', '2019-05-15'),
    ('soc009', 'cla010', '2019-05-15'),
    ('soc010', 'cla005', '2017-01-02'),
    ('soc011', 'cla004', '2018-04-05'),
    ('soc012', 'cla005', '2019-01-04'),
    ('soc012', 'cla007', '2019-01-04');

INSERT INTO 
  Paga_t(nro_socio, id_clase, fecha, monto)
VALUES
    ('soc001', 'cla004', '2019-10-10', '1500'),
    ('soc002', 'cla005', '2018-12-12', '800'),
    ('soc003', 'cla004', '2019-11-01', '1000'),
    ('soc003', 'cla005', '2019-11-01', '700'),
    ('soc010', 'cla005', '2016-10-19', '200'),
    ('soc011', 'cla004', '2018-08-24', '1050'),
    ('soc012', 'cla005', '2019-04-14', '800');

INSERT INTO
    Se_Inscribe_f(nro_socio, nro_orden, id_clase, fecha_inscrip)
VALUES
    ('soc001', '1', 'cla004', '2019-10-10'),
    ('soc001', '1', 'cla001', '2018-10-10'),
    ('soc001', '1', 'cla002', '2018-10-10'),
    ('soc001', '1', 'cla003', '2018-10-10'),
    ('soc001', '1', 'cla006', '2018-10-10'),
    ('soc001', '1', 'cla007', '2018-10-10'),
    ('soc001', '1', 'cla009', '2018-10-10'),
    ('soc001', '2', 'cla005', '2019-09-10'),
    ('soc002', '1', 'cla004', '2018-12-12'),
    ('soc003', '2', 'cla007', '2019-11-01'),
    ('soc003', '3', 'cla001', '2019-11-01'),
    ('soc004', '4', 'cla008', '2019-11-01'),
    ('soc004', '3', 'cla007', '2018-06-01'),
    ('soc004', '1', 'cla002', '2018-10-21'),
    ('soc004', '1', 'cla003', '2018-06-29'),
    ('soc005', '2', 'cla004', '2017-07-15'),
    ('soc005', '1', 'cla007', '2017-01-20'),
    ('soc005', '2', 'cla002', '2019-01-02'),
    ('soc006', '1', 'cla004', '2019-07-01'),
    ('soc007', '3', 'cla005', '2019-02-07'),
    ('soc007', '2', 'cla001', '2019-02-27'),
    ('soc007', '1', 'cla003', '2018-09-06'),
    ('soc008', '2', 'cla003', '2018-11-02'),
    ('soc008', '1', 'cla004', '2019-02-15'),
    ('soc009', '1', 'cla001', '2018-05-07'),
    ('soc009', '1', 'cla002', '2018-05-28'),
    ('soc009', '1', 'cla003', '2018-05-07'),
    ('soc009', '1', 'cla006', '2018-05-28'),
    ('soc009', '1', 'cla007', '2018-05-28'),
    ('soc009', '1', 'cla009', '2018-05-28'),
    ('soc009', '2', 'cla009', '2019-05-07'),
    ('soc010', '1', 'cla005', '2016-10-19'),
    ('soc010', '2', 'cla007', '2018-08-27'),
    ('soc011', '1', 'cla001', '2018-04-05'),
    ('soc011', '1', 'cla007', '2018-08-24'),
    ('soc011', '2', 'cla001', '2018-08-24'),
    ('soc011', '2', 'cla007', '2018-08-24'),
    ('soc011', '2', 'cla006', '2018-08-24'),
    ('soc011', '2', 'cla008', '2018-08-24'),
    ('soc011', '3', 'cla005', '2019-09-21'),
    ('soc012', '1', 'cla006', '2019-01-04'),
    ('soc012', '2', 'cla006', '2019-01-04'),
    ('soc012', '2', 'cla004', '2019-04-14'),
    ('soc012', '4', 'cla007', '2018-06-17'),
    #('soc012', '3', 'cla008', '2019-06-17'),
    ('soc013', '1', 'cla009', '2018-06-17');
    
INSERT INTO 
  Paga_f(nro_socio, nro_orden, id_clase, fecha, monto)
VALUES
    ('soc001', '1', 'cla004', '2019-10-20', '1500'),
    ('soc001', '2', 'cla005', '2019-11-28', '800'),
    ('soc002', '1', 'cla004', '2018-12-21', '1500'),
    ('soc005', '2', 'cla004', '2017-07-15', '1000'),
    ('soc006', '1', 'cla004', '2019-07-07', '1500'),
    ('soc007', '3', 'cla005', '2019-02-07', '800'),
    ('soc008', '1', 'cla004', '2019-02-15', '700'),
    ('soc010', '1', 'cla005', '2016-10-19', '200'),
    ('soc011', '3', 'cla005', '2019-09-21', '700'),
    ('soc012', '2', 'cla004', '2019-04-14', '100');

INSERT INTO
    Cuota(id_cuota, monto_base, periodo, fecha_cuota)
VALUES
    ('cuo001', 2874, '2018-10', '2018-11-16'),
    ('cuo002', 3300, '2018-11', '2018-12-08'),
    ('cuo003', 3893, '2018-12', '2019-01-12'),
    ('cuo004', 3467, '2019-01', '2019-02-14'),
    ('cuo005', 3467, '2019-02', '2019-03-13'),
    ('cuo006', 3467, '2019-03', '2019-04-08'),
    ('cuo007', 3217, '2019-04', '2019-05-09'),
    ('cuo008', 3217, '2019-05', '2019-06-20'),
    ('cuo009', 3217, '2019-06', '2019-07-15'),
    ('cuo010', 3415, '2019-07', '2019-08-11'),
    ('cuo011', 3217, '2019-08', '2019-09-10'),
    ('cuo012', 3345, '2019-09', '2019-10-14'),
    ('cuo013', 3345, '2019-10', '2019-11-11');

INSERT INTO
    Pago(id_cuota, nro_socio, monto_abonado, fecha_vencimiento, monto_pagar, fecha_pago)
VALUES
    ('cuo001', 'soc001', 7759.8, '2019-11-30', 7759.8, '2019-11-20'),
    ('cuo001', 'soc002', 2586.6, '2019-11-30', 2586.6, '2019-11-17'),
    ('cuo001', 'soc003', 6897.6, '2019-11-30', 6897.6, '2019-11-22'),
    ('cuo002', 'soc001', 8910, '2019-12-20', 8910, '2019-12-09'),
    ('cuo002', 'soc002', 2970, '2019-12-20', 2970, '2019-12-19'),
    ('cuo002', 'soc003', 7920, '2019-12-20', 7920, '2019-12-15'),
    ('cuo003', 'soc001', 10511.1, '2019-02-04', 10511.1, '2019-01-18'),
    ('cuo003', 'soc002', 3503.7, '2019-02-04', 3503.7, '2019-01-20'),
    ('cuo003', 'soc003', 9345.6, '2019-02-04', 9345.6, '2019-01-13'),
    ('cuo004', 'soc001', 9360.9, '2019-02-28', 9360.9, '2019-02-18'),
    ('cuo004', 'soc002', 3120.3, '2019-02-28', 3120.3, '2019-02-20'),
    ('cuo004', 'soc003', 8320.8, '2019-02-28', 8320.8, '2019-02-27'),
    ('cuo005', 'soc001', 9360.9, '2019-03-26', 9360.9, '2019-03-23'),
    ('cuo005', 'soc002', 3120.3, '2019-03-26', 3120.3, '2019-03-20'),
    ('cuo005', 'soc003', 8320.8, '2019-03-26', 8320.8, '2019-03-15'),
    ('cuo006', 'soc001', 9360.9, '2019-04-22', 9360.9, '2019-04-10'),
    ('cuo006', 'soc002', 3120.3, '2019-04-22', 3120.3, '2019-04-10'),
    ('cuo006', 'soc003', 8320.8, '2019-04-22', 8320.8, '2019-04-15'),
    ('cuo006', 'soc004', 13521.3, '2019-04-22',13521.3, '2019-04-20'),
    ('cuo007', 'soc001', 8413, '2019-05-21', 10133.55, '2019-05-10'), /*1720.55*/
    ('cuo007', 'soc002', 3377.85, '2019-05-21', 3377.85, '2019-05-15'),
    ('cuo007', 'soc003', 10937.8, '2019-05-21', 10937.8, '2019-05-19'),
    ('cuo007', 'soc004', 15602.45, '2019-05-21', 15602.45, '2019-05-15'),
    ('cuo008', 'soc001', 10133.55, '2019-07-02', 10133.55, '2019-06-23'),
    ('cuo008', 'soc002', 3377.85, '2019-07-02', 3377.85, '2019-06-24'),
    ('cuo008', 'soc003', 10937.8, '2019-07-02', 10937.8, '2019-06-23'),
    ('cuo008', 'soc004', 10602, '2019-07-02', 15602.45, '2019-06-25'),/*5000.45*/
    ('cuo008', 'soc005', 12224.6, '2019-07-02', 12224.6, '2019-06-30'),
    ('cuo008', 'soc006', 6755.7, '2019-07-02', 6755.7, '2019-06-01'),
    ('cuo009', 'soc001', 10133.55, '2019-07-27', 10133.55, '2019-07-16'),
    ('cuo009', 'soc002', 3377.85, '2019-07-27', 3377.85, '2019-07-16'),
    ('cuo009', 'soc003', 10937.8, '2019-07-27', 10937.8, '2019-07-16'),
    ('cuo009', 'soc004', 15602.45, '2019-07-27', 15602.45, '2019-07-20'),
    ('cuo009', 'soc005', 12224.6, '2019-07-27', 12224.6, '2019-07-24'),
    ('cuo009', 'soc006', 6755.7, '2019-07-27', 6755.7, '2019-07-27'),
    ('cuo009', 'soc007', 9490.15, '2019-07-27', 9490.15, '2019-07-18'),
    ('cuo010', 'soc001', 12477.8, '2019-08-22', 10757.25, '2019-08-12'),
    ('cuo007', 'soc001', 1720.55, '2019-05-21', 10133.55, '2019-08-12'),/* deuda ATRASADA*/
    ('cuo010', 'soc002', 3585.75, '2019-08-22', 3585.75, '2019-08-13'),
    ('cuo010', 'soc003', 11611, '2019-08-22', 11611, '2019-08-13'),
    ('cuo010', 'soc004', 16562.75, '2019-08-22', 16562.75, '2019-08-13'),
    ('cuo010', 'soc005', 10000, '2019-08-22', 12977, '2019-08-14'),/*2977*/
    ('cuo010', 'soc006', 7171.5, '2019-08-22', 7171.5, '2019-08-18'),
    ('cuo010', 'soc007', 10073.4, '2019-08-22', 10073.4, '2019-08-12'),
    ('cuo010', 'soc008', 9391.25, '2019-08-22', 9391.25, '2019-08-20'),
    ('cuo010', 'soc009', 5805.5, '2019-08-22', 5805.5, '2019-08-14'),
    ('cuo011', 'soc001', 10133.55, '2019-09-22', 10133.55, '2019-09-22'),
    ('cuo011', 'soc002', 3377.85, '2019-09-22', 3377.85, '2019-09-21'),
    ('cuo011', 'soc003', 10937.8, '2019-09-22', 10937.8, '2019-09-13'),
    ('cuo011', 'soc004', 20602.9, '2019-09-22', 15602.45, '2019-09-20'),
    ('cuo008', 'soc004', 5000.45, '2019-07-02', 15602.45, '2019-09-20'),/*Paga deuda ATRASADA*/
    ('cuo011', 'soc005', 15201.6, '2019-09-22', 12224.6, '2019-09-11'),
    ('cuo010', 'soc005', 2977, '2019-08-22', 12977, '2019-09-11'),/*Paga deuda ATRASADA*/
    ('cuo011', 'soc006', 6755.7, '2019-09-22', 6755.7, '2019-09-13'),
    ('cuo011', 'soc007', 9490.15, '2019-09-22', 9490.15, '2019-09-10'),
    ('cuo011', 'soc008', 8846.75, '2019-09-22', 8846.75, '2019-09-11'),
    ('cuo011', 'soc009', 3218.7, '2019-09-22', 3218.7, '2019-09-15'),
    ('cuo011', 'soc010', 10133.55, '2019-09-22', 10133.55, '2019-09-18'),
    ('cuo012', 'soc001', 10336.05, '2019-10-26', 10336.05, '2019-10-15'),
    ('cuo012', 'soc002', 3445.35, '2019-10-26', 3445.35, '2019-10-16'),
    ('cuo012', 'soc003', 9366, '2019-10-26', 9366, '2019-10-16'),
    ('cuo012', 'soc004', 15019.05, '2019-10-26', 15019.05, '2019-10-15'),
    ('cuo012', 'soc005', 11573.7, '2019-10-26', 11573.7, '2019-10-15'),
    ('cuo012', 'soc006', 6890.7, '2019-10-26', 6890.7, '2019-10-18'),
    ('cuo012', 'soc007', 4000, '2019-10-26', 9232.2, '2019-10-21'),/*5232.2*/
    ('cuo012', 'soc008', 8128.35, '2019-10-26', 8128.35, '2019-10-18'),
    ('cuo012', 'soc009', 4683, '2019-10-26', 4683, '2019-10-20'),
    ('cuo012', 'soc010', 10336.05, '2019-10-26', 10336.05, '2019-10-21'),
    ('cuo012', 'soc011', 16122.9, '2019-10-26', 16122.9, '2019-10-25'),
    ('cuo012', 'soc012', 12811.35, '2019-10-26', 12811.35, '2019-10-22'),
    ('cuo012', 'soc013', 8128.35, '2019-10-26', 8128.35, '2019-10-26'),
    ('cuo013', 'soc001', 10336.05, '2019-11-22', 10336.05, '2019-11-12'),
    ('cuo013', 'soc002', 3445.35, '2019-11-22', 3445.35, '2019-11-14'),
    ('cuo013', 'soc003', 9366, '2019-11-22', 9366, '2019-11-13'),
    ('cuo013', 'soc004', 15019.05, '2019-11-22', 15019.05, '2019-11-12'),
    ('cuo013', 'soc005', 11573.7, '2019-11-22', 11573.7, '2019-11-15'),
    ('cuo013', 'soc006', 6890.7, '2019-11-22', 6890.7, '2019-11-21'),
    ('cuo013', 'soc007', 9232.2, '2019-11-22', 9232.2, '2019-11-13'),
    ('cuo013', 'soc008', 6128.35, '2019-11-22', 8128.35, '2019-11-15'),/* deuda 2mil */
    ('cuo013', 'soc009', 4683, '2019-11-22', 4683, '2019-11-17'),
    ('cuo013', 'soc010', 10336.05, '2019-11-22', 10336.05, '2019-11-22'),
    ('cuo013', 'soc011', 16122.9, '2019-11-22', 16122.9, '2019-11-22'),
    ('cuo013', 'soc012', 11811.35, '2019-11-22', 12811.35, '2019-11-20'),  /* deuda 1000 */
    ('cuo013', 'soc013', 8128.35, '2019-11-22', 8128.35, '2019-11-20');

/*
 * La cantidad de socios por categoría que se hayan inscripto en todas las actividades 
 * gratuitas durante el año pasado.
 */
delimiter //
CREATE PROCEDURE soc_act_gratuitas ()
    BEGIN
        DECLARE anioAux int;
        #cambie aca por que el nombre de la variable era diferente a como se usaba y volvia a calcular 
        #algo innecesario, por eso ahora es entera (solo precisa el año)
        SELECT YEAR(CURRENT_DATE())-1 INTO anioAux; 
        
        SELECT 
            id_categoria, SUM(cant) AS cantSocios
        FROM
        (
            /* cant titutales por categoria */
            SELECT 
                t.id_categoria, COUNT(*) AS cant
            FROM 
                Titular t
            WHERE NOT EXISTS
            (
                SELECT *
                FROM 
                    Clase c, Actividad a
                WHERE 
                    (a.id_categoria = t.id_categoria OR a.id_categoria IS NULL) AND 
                    c.cod_actividad = a.cod_actividad AND 
                    a.arancelada IS FALSE AND
                    NOT EXISTS
                    (
                        SELECT *
                        FROM 
                            Se_Inscribe_t st
                        WHERE 
                            st.nro_socio = t.nro_socio AND 
                            st.id_clase = c.id_clase AND 
                            YEAR(st.fecha_inscrip) = anioAux
                    )
            )
            GROUP BY 
                id_categoria

            union all

            /* cant familiares por categoria */
            SELECT 
                f.id_categoria, COUNT(*) AS cant
            FROM 
                Familiar f
            WHERE NOT EXISTS
            (
                SELECT *
                FROM 
                    Clase c, Actividad a
                WHERE 
                    (a.id_categoria = f.id_categoria OR a.id_categoria IS NULL) AND 
                    c.cod_actividad = a.cod_actividad AND
                    a.arancelada IS FALSE AND 
                    NOT EXISTS
                    (
                        SELECT *
                        FROM 
                            Se_Inscribe_f sf
                        WHERE 
                            sf.nro_socio = f.nro_socio AND 
                            sf.nro_orden = f.nro_orden AND 
                            sf.id_clase = c.id_clase AND 
                            YEAR(sf.fecha_inscrip) = anioAux
                    )
            )
            GROUP BY id_categoria
        ) as sociosxcat #es necesario esto por que sino no compila
        GROUP BY id_categoria;
    END//

/*
 * Los datos del socio titular de grupos familiares que adeuden cuotas sociales del año en
 * curso, junto con el importe total adeudado, y la cantidad de integrantes del grupo.
 */
CREATE PROCEDURE soc_deudores ()
    BEGIN
        DECLARE anioAux int;
        SELECT YEAR(CURRENT_DATE()) INTO anioAux;

        SELECT
            t.nro_socio, t.nombre, t.apellido, SUM(calculaDeuda(t.nro_socio, c.id_cuota, p.monto_pagar)) AS deuda, cant_Familiares(t.nro_socio) AS cantFamiliares
        FROM
            Titular t, Pago p, Cuota c
        WHERE
            p.nro_socio = t.nro_socio AND 
            p.id_cuota = c.id_cuota AND 
            YEAR(c.fecha_cuota) = anioAux AND 
            p.fecha_pago < p.fecha_vencimiento
        GROUP BY
            t.nro_socio, c.id_cuota, t.nombre, t.apellido, p.monto_pagar
        HAVING
            SUM(p.monto_abonado) < p.monto_pagar;
    END//

CREATE FUNCTION calculaDeuda(socio varchar(15), cuota varchar(15), montoPagar float)
    RETURNS float
    BEGIN
        DECLARE rta float;
        SELECT
            montoPagar - SUM(p.monto_abonado)
        INTO
            rta
        FROM
            Pago p
        WHERE
            p.id_cuota = cuota AND
            p.nro_socio = socio AND
            p.fecha_pago < p.fecha_vencimiento;
        RETURN rta;
    END; //


CREATE FUNCTION cant_Familiares (nroSoc varchar(15))
    RETURNS int
    BEGIN
        DECLARE cant int;
        SELECT 
            COUNT(*) 
        INTO 
            cant
        FROM 
            Titular t, Familiar f
        WHERE 
            t.nro_socio = nroSoc AND 
            t.nro_socio = f.nro_socio;
        RETURN cant;
    END; //
delimiter ;

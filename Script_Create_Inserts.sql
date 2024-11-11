create database sistema_permisosV3;
use sistema_permisosV3;

-- Tabla Branch Office (para pruebas)
CREATE TABLE BranchOffice (
    id_branch INT IDENTITY(1,1) PRIMARY KEY,
    branch_name NVARCHAR(255) NOT NULL
);

-- Tabla Company (compañía usando el ERP)
CREATE TABLE Company (
    id_compa BIGINT IDENTITY(1,1) PRIMARY KEY,
    compa_name NVARCHAR(255) NOT NULL
);

-- Tabla Cost Center (para pruebas)
CREATE TABLE CostCenter (
    id_cost INT IDENTITY(1,1) PRIMARY KEY,
    cost_name NVARCHAR(255) NOT NULL
);

-- Tabla Entity Catalog (para almacenar todas las entidades del sistema)
CREATE TABLE EntityCatalog (
    id_entit INT IDENTITY(1,1) PRIMARY KEY,
    entit_name NVARCHAR(255) NOT NULL UNIQUE,
    entit_descrip NVARCHAR(255) NOT NULL,
    entit_active BIT NOT NULL DEFAULT 1,
    entit_config NVARCHAR(MAX) NULL
);

-- Tabla Permission (almacena todas las combinaciones de permisos posibles)
CREATE TABLE Permission (
    id_permi BIGINT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    can_create BIT NOT NULL DEFAULT 0,
    can_read BIT NOT NULL DEFAULT 0,
    can_update BIT NOT NULL DEFAULT 0,
    can_delete BIT NOT NULL DEFAULT 0,
    can_import BIT NOT NULL DEFAULT 0,
    can_export BIT NOT NULL DEFAULT 0
);

-- Tabla Role (define roles en una compañía)
CREATE TABLE Role (
    id_role BIGINT IDENTITY(1,1) PRIMARY KEY,
    company_id BIGINT NOT NULL,
    CONSTRAINT FK_Role_Company FOREIGN KEY (company_id) REFERENCES Company(id_compa),
    role_name NVARCHAR(255) NOT NULL,
    role_code NVARCHAR(255) NOT NULL,
    role_description NVARCHAR(MAX) NULL,
    role_active BIT NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Company_RoleCode UNIQUE (company_id, role_code)
);

-- Tabla User (usuario del sistema)
CREATE TABLE [User] (
    id_user BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_name NVARCHAR(255) NOT NULL
);

-- Tabla User_Company (relación muchos a muchos entre usuario y compañía)
CREATE TABLE UserCompany (
    id_useco BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id BIGINT NOT NULL,
    company_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    CONSTRAINT FK_UserCompany_User FOREIGN KEY (user_id) REFERENCES [User](id_user),
    CONSTRAINT FK_UserCompany_Company FOREIGN KEY (company_id) REFERENCES Company(id_compa),
    CONSTRAINT FK_UserCompany_Role FOREIGN KEY (role_id) REFERENCES Role(id_role),
    CONSTRAINT UQ_UserCompany UNIQUE (user_id, company_id, role_id)
);

-- Tabla PermiRole (permisos asignados a roles sobre entidades completas)
CREATE TABLE PermiRole (
    id_perol BIGINT IDENTITY(1,1) PRIMARY KEY,
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    entitycatalog_id INT NOT NULL, -- Cambiado a INT para que coincida con id_entit en EntityCatalog
    perol_include BIT NOT NULL DEFAULT 1,
    perol_record BIGINT NULL,
    CONSTRAINT FK_PermiRole_Role FOREIGN KEY (role_id) REFERENCES Role(id_role),
    CONSTRAINT FK_PermiRole_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi),
    CONSTRAINT FK_PermiRole_EntityCatalog FOREIGN KEY (entitycatalog_id) REFERENCES EntityCatalog(id_entit),
    CONSTRAINT UQ_Role_Permission_Entity_Record UNIQUE (role_id, permission_id, entitycatalog_id, perol_record)
);

-- Tabla PermiUser (permisos asignados a usuarios sobre entidades completas)
CREATE TABLE PermiUser (
    id_peusr BIGINT IDENTITY(1,1) PRIMARY KEY,
    usercompany_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    entitycatalog_id INT NOT NULL, -- Cambiado a INT para que coincida con id_entit en EntityCatalog
    peusr_include BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_PermiUser_UserCompany FOREIGN KEY (usercompany_id) REFERENCES UserCompany(id_useco),
    CONSTRAINT FK_PermiUser_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi),
    CONSTRAINT FK_PermiUser_EntityCatalog FOREIGN KEY (entitycatalog_id) REFERENCES EntityCatalog(id_entit),
    CONSTRAINT UQ_UserCompany_Permission_Entity UNIQUE (usercompany_id, permission_id, entitycatalog_id)
);

-- Tabla PermiRoleRecord (permisos específicos para roles sobre registros individuales)
CREATE TABLE PermiRoleRecord (
    id_perol BIGINT IDENTITY(1,1) PRIMARY KEY,
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    entitycatalog_id INT NOT NULL,
    perol_record BIGINT NULL,
    perol_include BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_PermiRoleRecord_Role FOREIGN KEY (role_id) REFERENCES Role(id_role),
    CONSTRAINT FK_PermiRoleRecord_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi),
    CONSTRAINT FK_PermiRoleRecord_EntityCatalog FOREIGN KEY (entitycatalog_id) REFERENCES EntityCatalog(id_entit),
    -- Cambiar el nombre de la restricción a uno único para evitar conflicto
    CONSTRAINT UQ_Role_Permission_Entity_Record_Role UNIQUE (role_id, permission_id, entitycatalog_id, perol_record)
);

-- Tabla PermiUserRecord (permisos específicos para usuarios sobre registros individuales)
CREATE TABLE PermiUserRecord (
    id_peusr BIGINT IDENTITY(1,1) PRIMARY KEY, 
    usercompany_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    entitycatalog_id INT NOT NULL,
    peusr_record BIGINT NOT NULL,
    peusr_include BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_PermiUserRecord_UserCompany FOREIGN KEY (usercompany_id) REFERENCES UserCompany(id_useco),
    CONSTRAINT FK_PermiUserRecord_Permission FOREIGN KEY (permission_id) REFERENCES Permission(id_permi),
    CONSTRAINT FK_PermiUserRecord_EntityCatalog FOREIGN KEY (entitycatalog_id) REFERENCES EntityCatalog(id_entit),
    CONSTRAINT UQ_UserCompany_Permission_Entity_Record UNIQUE (usercompany_id, permission_id, entitycatalog_id, peusr_record)
);

-- INSERTS para pruebas
-- Company
INSERT INTO Company (compa_name) VALUES ('Empresa Test');

-- Branch Office
INSERT INTO BranchOffice (branch_name) VALUES ('Sucursal Central');

-- Cost Center
INSERT INTO CostCenter (cost_name) VALUES ('Centro de Costo Principal');

-- Entity Catalog
INSERT INTO EntityCatalog (entit_name, entit_descrip) VALUES 
('BranchOffice', 'Sucursal para pruebas'),
('CostCenter', 'Centro de costo para pruebas'),
('Employee', 'Entidad de empleados');

-- Permission: combinaciones CRUD, importar y exportar
DECLARE @i INT = 0;
WHILE @i < 64
BEGIN
    INSERT INTO Permission (
        name, description, 
        can_create, can_read, can_update, can_delete, 
        can_import, can_export)
    VALUES (
        'Permiso_' + CAST(@i AS NVARCHAR), 
        'Descripción de permiso ' + CAST(@i AS NVARCHAR),
        CAST((@i & 1) AS BIT),
        CAST((@i & 2) / 2 AS BIT),
        CAST((@i & 4) / 4 AS BIT),
        CAST((@i & 8) / 8 AS BIT),
        CAST((@i & 16) / 16 AS BIT),
        CAST((@i & 32) / 32 AS BIT)
    );
    SET @i = @i + 1;
END;

-- Role
INSERT INTO Role (company_id, role_name, role_code) VALUES 
(1, 'Contador', 'CONT'),
(1, 'Recursos Humanos', 'RH');

-- User
INSERT INTO [User] (user_name) VALUES ('Usuario Prueba');

-- UserCompany
INSERT INTO UserCompany (user_id, company_id, role_id) VALUES 
(1, 1, 1); -- Usuario en rol "Contador" para "Empresa Test"

-- Permisos de Rol sobre entidades completas
INSERT INTO PermiRole (role_id, permission_id, entitycatalog_id, perol_include) VALUES 
(1, 1, 1, 1); -- Ejemplo de permiso para "Contador" en "Sucursal Central"

-- Permisos de Usuario sobre registros específicos
INSERT INTO PermiUserRecord (usercompany_id, permission_id, entitycatalog_id, peusr_record, peusr_include) VALUES 
(1, 2, 1, 1, 1); -- Permiso específico del usuario sobre un registro de "Sucursal Central"
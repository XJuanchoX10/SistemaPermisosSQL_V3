CREATE PROCEDURE GetUserPermissions 
    @UserID BIGINT, 
    @EntityID BIGINT
AS
BEGIN
    -- Crear tabla temporal para almacenar permisos combinados
    CREATE TABLE #UserPermissions (
        id_permi BIGINT,
        name NVARCHAR(255),
        description NVARCHAR(MAX),
        can_create BIT,
        can_read BIT,
        can_update BIT,
        can_delete BIT,
        can_import BIT,
        can_export BIT
    );

    -- Consultar permisos a nivel de rol sobre entidad completa
    INSERT INTO #UserPermissions
    SELECT p.id_permi, p.name, p.description, 
           p.can_create, p.can_read, p.can_update, p.can_delete, 
           p.can_import, p.can_export
    FROM Permission p
    INNER JOIN PermiRole pr ON pr.permission_id = p.id_permi
    INNER JOIN Role r ON pr.role_id = r.id_role
    INNER JOIN UserCompany uc ON uc.role_id = r.id_role
    WHERE uc.user_id = @UserID AND pr.entitycatalog_id = @EntityID
          AND pr.perol_include = 1;

    -- Actualizar permisos a nivel de usuario sobre entidad completa
    MERGE INTO #UserPermissions AS target
    USING (
        SELECT p.id_permi, p.name, p.description, 
               p.can_create, p.can_read, p.can_update, p.can_delete, 
               p.can_import, p.can_export
        FROM Permission p
        INNER JOIN PermiUser pu ON pu.permission_id = p.id_permi
        WHERE pu.usercompany_id = @UserID AND pu.entitycatalog_id = @EntityID
              AND pu.peusr_include = 1
    ) AS source
    ON target.id_permi = source.id_permi
    WHEN MATCHED THEN
        UPDATE SET 
            target.can_create = source.can_create,
            target.can_read = source.can_read,
            target.can_update = source.can_update,
            target.can_delete = source.can_delete,
            target.can_import = source.can_import,
            target.can_export = source.can_export
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (id_permi, name, description, can_create, can_read, can_update, 
                can_delete, can_import, can_export)
        VALUES (source.id_permi, source.name, source.description, 
                source.can_create, source.can_read, source.can_update, 
                source.can_delete, source.can_import, source.can_export);

    -- Excluir permisos a nivel de registro de rol
    DELETE FROM #UserPermissions
    WHERE EXISTS (
        SELECT 1
        FROM PermiRoleRecord prr
        WHERE prr.permission_id = #UserPermissions.id_permi
              AND prr.entitycatalog_id = @EntityID
              AND prr.perol_record IS NOT NULL
              AND prr.perol_include = 0
    );

    -- Incluir permisos a nivel de registro de usuario
    INSERT INTO #UserPermissions
    SELECT p.id_permi, p.name, p.description, 
           p.can_create, p.can_read, p.can_update, p.can_delete, 
           p.can_import, p.can_export
    FROM Permission p
    INNER JOIN PermiUserRecord pur ON pur.permission_id = p.id_permi
    WHERE pur.usercompany_id = @UserID 
          AND pur.entitycatalog_id = @EntityID
          AND pur.peusr_record IS NOT NULL
          AND pur.peusr_include = 1;

    -- Excluir permisos a nivel de registro de usuario
    DELETE FROM #UserPermissions
    WHERE EXISTS (
        SELECT 1
        FROM PermiUserRecord pur
        WHERE pur.permission_id = #UserPermissions.id_permi
              AND pur.entitycatalog_id = @EntityID
              AND pur.peusr_record IS NOT NULL
              AND pur.peusr_include = 0
    );

    -- Mostrar permisos finales para el usuario en la entidad específica
    SELECT * FROM #UserPermissions;

    -- Limpiar tabla temporal
    DROP TABLE #UserPermissions;
END;

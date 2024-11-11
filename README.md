# SistemaPermisosSQL_V3
Sistema de permisos en SQL Server

Orden de ejecucion de Scripts
1. Compilar el archivo Script_Create_Inserts.sql el cual contiene la creacion de la base de datos, la creacion de las tablas y los insert de las mismas.
2. Compilar el archivo Script_SP_GetUserPermissions.sql el cual contiene el procedimiento almacenado que se explicara a continuacion:

Explicación Paso a Paso del Procedimiento

    Tabla Temporal #UserPermissions:
        Creamos una tabla temporal para almacenar todos los permisos que se combinarán a medida que avanzamos en el procedimiento.

    Insertar Permisos de Rol a Nivel de Entidad Completa:
        Insertamos los permisos asignados a cualquier rol que tenga el usuario sobre la entidad completa. Esto es la base, y cualquier permiso adicional o exclusión modificará esta entrada.

    Actualizar con Permisos de Usuario a Nivel de Entidad Completa:
        Utilizamos una operación MERGE para actualizar los permisos del usuario sobre la entidad si el usuario tiene permisos individuales que sobrescriben los de su rol.

    Excluir Permisos a Nivel de Registro de Rol:
        Eliminamos los permisos que hayan sido excluidos específicamente a nivel de registro en la tabla PermiRoleRecord.

    Incluir Permisos a Nivel de Registro de Usuario:
        Insertamos los permisos a nivel de registro específico que han sido asignados al usuario, sobrescribiendo cualquier configuración de rol.

    Excluir Permisos a Nivel de Registro de Usuario:
        Excluimos permisos específicos a nivel de registro en PermiUserRecord cuando estos han sido configurados como include = 0.

    Resultado Final:
        Seleccionamos los permisos finales resultantes de la jerarquización, los cuales representan los permisos efectivos del usuario en la entidad solicitada.

3. Compilar el archivo Script_Exec_SP_GetUserPermissions.sql que contiene la ejecucion del SP para la prueba.

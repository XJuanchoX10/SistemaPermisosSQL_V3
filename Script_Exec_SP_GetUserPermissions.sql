--Ejecuci�n de Prueba del Procedimiento Almacenado
--Suponiendo que deseamos obtener los permisos para un usuario con UserID = 1 en una entidad con EntityID = 1

EXEC GetUserPermissions @UserID = 1, @EntityID = 1;

--Permiso_0: No otorga ning�n derecho espec�fico.
--Permiso_1: Solo permite la acci�n de crear registros en la entidad especificada.
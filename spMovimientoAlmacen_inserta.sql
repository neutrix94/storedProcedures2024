DROP PROCEDURE IF EXISTS spMovimientoAlmacen_inserta;
DELIMITER $$
CREATE procedure spMovimientoAlmacen_inserta (
 IN id_usuario INT
,IN observaciones INT
,IN id_sucursal INT
,IN id_almacen INT
,IN id_tipo_movimiento INT
,IN id_pedido INT
,IN id_orden_compra INT
,IN id_maquila INT
,IN id_transferencia INT
,IN id_pantalla	INT )
BEGIN
DECLARE query VARCHAR(2500);
DECLARE varid INT;

INSERT INTO ec_movimiento_almacen (
 id_tipo_movimiento
,id_usuario
,id_sucursal
,fecha
,hora
,observaciones
,id_pedido
,id_orden_compra
,lote
,id_maquila
,id_transferencia
,id_almacen
,id_pantalla)

SELECT 
 id_tipo_movimiento
,id_usuario
,id_sucursal
,now()
,now()
,observaciones
,id_pedido
,id_orden_compra
,-1
,id_maquila
,id_transferencia
,id_almacen
,id_pantalla;

SET varid= (SELECT MAX(id_movimiento_almacen) FROM ec_movimiento_almacen);

SET query = (SELECT concat('INSERT INTO ec_movimiento_almacen (id_tipo_movimiento,id_usuario,id_sucursal,fecha,hora,observaciones,id_pedido, id_orden_compra,lote,id_maquila,id_transferencia,id_almacen,id_pantalla)
SELECT ',IFNULL(id_tipo_movimiento,0),',',IFNULL(id_usuario,0),',id_sucursal,',now(),',',now(),',',IFNULL(observaciones,0),',',IFNULL(id_pedido,0),',',IFNULL(id_orden_compra,0),',-1,',IFNULL(id_maquila,0),',',IFNULL(id_transferencia,0),',',IFNULL(id_almacen,0),',',IFNULL(id_pantalla,0),' FROM sys_sucursales WHERE id_sucursal=',IFNULL(id_sucursal,0)));


INSERT INTO ec_bitacora_movimiento_consulta (id_registro,nombre_tabla,id_pantalla_movimientos_almacen,id_tipo_consulta,sentencia_query )
VALUES (varid,'ec_movimiento_almacen',id_pantalla,1,query);

END

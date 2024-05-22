DROP PROCEDURE IF EXISTS SpMovimientoAlmacen_elimina;
DELIMITER $$
create procedure SpMovimientoAlmacen_elimina (
 IN id_mov_almacen INT,
 IN idpantalla INT) 

BEGIN 
DECLARE query1 VARCHAR(2500);

/*verificado 13-07-2023*/
	DELETE FROM ec_movimiento_detalle_proveedor_producto WHERE id_movimiento_almacen_detalle IN(
	SELECT id_movimiento_almacen_detalle FROM ec_movimiento_detalle WHERE id_movimiento = id_mov_almacen
	);

SET query1 = (SELECT concat(IFNULL(`id_movimiento_almacen`,0),',',IFNULL(`id_tipo_movimiento`,0),',',IFNULL(`id_usuario`,0),',',IFNULL(`id_sucursal`,0),',',IFNULL(`fecha`,0),',',IFNULL(`hora`,0),',',IFNULL(`observaciones`,0),',',IFNULL( `id_pedido`,0),',',IFNULL(`id_orden_compra`,0),',',IFNULL(`lote`,0),',',IFNULL(`id_maquila`,0),',',IFNULL(`id_transferencia`,0),',',IFNULL(`id_almacen`,0),',',IFNULL(`status_agrupacion`,0),',',IFNULL(`id_equivalente`,0),',',IFNULL(`folio_unico`,0),',',IFNULL(`insertado_por_sincronizacion`,0),',',IFNULL(`ultima_sincronizacion`,0),',',IFNULL(`ultima_actualizacion`,0),',',IFNULL(`sincronizar`,0)) FROM `ec_movimiento_almacen` WHERE id_movimiento_almacen = id_mov_almacen );

DELETE FROM ec_movimiento_almacen WHERE id_movimiento_almacen = id_mov_almacen;

INSERT INTO ec_bitacora_movimiento_consulta (id_registro,nombre_tabla,id_pantalla_movimientos_almacen,id_tipo_consulta,regs_before )
VALUES (id_mov_almacen,'ec_movimiento_almacen',idpantalla,3,query1);

END;




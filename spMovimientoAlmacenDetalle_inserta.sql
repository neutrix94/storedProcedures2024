DROP PROCEDURE IF EXISTS spMovimientoAlmacenDetalle_inserta;
DELIMITER $$
create procedure spMovimientoAlmacenDetalle_inserta (
 IN id_mov INT
,IN idproducto INT
,IN cantidad INT
,IN cantidad_surtida INT
,IN id_pedido_detalle INT
,IN id_oc_detalle INT
,IN id_proveedor_producto INT
,IN idpantalla INT) 

BEGIN 
DECLARE query VARCHAR(2500);
DECLARE varid INT;
DECLARE id_almacen INTEGER(11);
DECLARE tipo INTEGER(2);
DECLARE id_tipo INTEGER(2);
DECLARE es_resolucion INTEGER(1);
DECLARE sucursal_id INT;
DECLARE folio VARCHAR( 20 );
DECLARE folio_unico_movimiento_almacen BIGINT( 20 );

INSERT INTO ec_movimiento_detalle(id_movimiento, id_producto, cantidad, cantidad_surtida, id_pedido_detalle, id_oc_detalle)  VALUES(id_mov,idproducto,cantidad,cantidad_surtida,id_pedido_detalle,id_oc_detalle);

SET varid= (SELECT MAX(id_movimiento_almacen_detalle) FROM ec_movimiento_detalle);

SET query = concat(' INSERT INTO ec_movimiento_detalle(id_movimiento, id_producto, cantidad, cantidad_surtida, id_pedido_detalle, id_oc_detalle)  VALUES(',',',IFNULL(id_mov,0),',',IFNULL(idproducto,0),',',IFNULL(cantidad,0),',',IFNULL(cantidad_surtida,0),',',IFNULL(id_pedido_detalle,0),',',IFNULL(id_oc_detalle,0),'); ');

INSERT INTO ec_bitacora_movimiento_consulta (id_registro ,nombre_tabla ,id_pantalla_movimientos_almacen ,id_tipo_consulta ,sentencia_query )
VALUES (varid,'ec_movimiento_detalle',idpantalla,1,query);

    SELECT
      ma.id_almacen,
      tm.afecta,
      ma.id_tipo_movimiento,
      ma.id_sucursal,
      ma.folio_unico,
      IF(ma.id_transferencia!=-1,t.es_resolucion,0)
      INTO
      id_almacen,
      tipo,
      id_tipo,
      sucursal_id,
      folio_unico_movimiento_almacen,
      es_resolucion
    FROM ec_movimiento_almacen ma
    LEFT JOIN ec_tipos_movimiento tm 
    ON ma.id_tipo_movimiento=tm.id_tipo_movimiento
    LEFT JOIN ec_transferencias t ON t.id_transferencia = ma.id_transferencia
    WHERE ma.id_movimiento_almacen=id_mov;

/*resetea las raciones*/
    IF(id_almacen=1 AND ( id_tipo=1 OR id_tipo=9 OR id_tipo=14 ) AND es_resolucion = 0 )
    THEN
      UPDATE sys_sucursales_producto SET
        stock_bajo=0,
        ajuste_realizado=0,
        racion_1=0,
        racion_2=0,
        racion_3=0
      WHERE id_producto=idproducto;

      DELETE FROM ec_exclusiones_transferencia WHERE id_producto=idproducto;
    END IF;

    UPDATE ec_almacen_producto ap
        SET ap.inventario = ap.inventario + ( ( cantidad * tipo ) )
    WHERE ap.id_producto = idproducto
    AND ap.id_almacen = id_almacen;  

    IF( id_proveedor_producto != '' AND id_proveedor_producto IS NOT NULL AND id_proveedor_producto != -1 ) 
    THEN
      INSERT INTO ec_movimiento_detalle_proveedor_producto ( id_movimiento_detalle_proveedor_producto, id_movimiento_almacen_detalle,
      id_proveedor_producto, cantidad, fecha_registro, id_sucursal, status_agrupacion, id_tipo_movimiento, id_almacen,id_pantalla )
      VALUES( NULL, varid, id_proveedor_producto, cantidad, NOW(),
      sucursal_id, -1, id_tipo, id_almacen,-1 );
    END IF;  

END
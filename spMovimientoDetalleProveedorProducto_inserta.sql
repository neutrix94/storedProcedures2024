DROP PROCEDURE IF EXISTS spMovimientoDetalleProveedorProducto_inserta;
DELIMITER $$
create procedure spMovimientoDetalleProveedorProducto_inserta (
 IN id_movimiento_almacen_detalle INTEGER(11)
,IN id_proveedor_producto INTEGER(11)
,IN cantidad FLOAT
,IN id_sucursal INTEGER(11)
,IN id_tipo_movimiento INTEGER(11)
,IN id_almacen INTEGER(11)
,IN id_pedido_validacion INT
,IN idpantalla INT ) 
BEGIN 
DECLARE query VARCHAR(2500);
DECLARE final_inventory FLOAT;
DECLARE folio VARCHAR(20);
DECLARE varid INT;


INSERT INTO ec_movimiento_detalle_proveedor_producto ( id_movimiento_almacen_detalle,
     id_proveedor_producto, cantidad, fecha_registro, id_sucursal, status_agrupacion, id_tipo_movimiento, id_almacen, id_pedido_validacion, id_pantalla )
     VALUES( NULL, id_proveedor_producto, cantidad, NOW(),
     id_sucursal, -1, id_tipo_movimiento, id_almacen,id_pedido_validacion, idpantalla);

SET varid= (SELECT MAX(id_movimiento_detalle_proveedor_producto) FROM ec_movimiento_detalle_proveedor_producto);

SET query = concat(' INSERT INTO ec_movimiento_detalle_proveedor_producto ( id_movimiento_detalle_proveedor_producto, id_movimiento_almacen_detalle,
     id_proveedor_producto, cantidad, fecha_registro, id_sucursal, status_agrupacion, id_tipo_movimiento, id_almacen,id_pedido_validacion, id_pantalla )
     VALUES( NULL,',',',id_movimiento_almacen_detalle,',',id_proveedor_producto,',',cantidad,',',NOW(),',',
     id_sucursal,',-1',',',id_tipo_movimiento,',',id_almacen,',',id_pedido_validacion,',',idpantalla,' );');

INSERT INTO ec_bitacora_movimiento_consulta (id_registro ,nombre_tabla ,id_pantalla_movimientos_almacen ,id_tipo_consulta ,sentencia_query )
VALUES (varid,'ec_movimiento_detalle_proveedor_producto',idpantalla,1,query);

		SET final_inventory = ( ( cantidad * (SELECT tm.afecta FROM ec_tipos_movimiento tm WHERE tm.id_tipo_movimiento = id_tipo_movimiento) ) );
		UPDATE ec_inventario_proveedor_producto 
		SET inventario = ( inventario + final_inventory )
		WHERE id_proveedor_producto = id_proveedor_producto 
		AND id_almacen = id_almacen;

END
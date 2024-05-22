DROP PROCEDURE IF EXISTS SpMovimientoDetalleProveedorProducto_elimina;
DELIMITER $$
create procedure SpMovimientoDetalleProveedorProducto_elimina (
 IN id_mov_detalle_proveedor_prod INT
,IN idpantalla INT) 

BEGIN
/*verificado 13-07-2023*/
    DECLARE store_id INTEGER;
    DECLARE final_inventory FLOAT;
    DECLARE id_suc INT;
    DECLARE f_unico varchar(30);
    DECLARE id_tipo_mov INT;	
    DECLARE cant float(15,4);
    DECLARE id_proveedor_prod INT;	
    DECLARE id_alm INT;	
    DECLARE query VARCHAR(2500);

    SELECT 
	id_sucursal,
	folio_unico,
	id_tipo_movimiento,
	cantidad,
	id_proveedor_producto,
	id_almacen 
	INTO
	id_suc,
        f_unico,
        id_tipo_mov,
        cant,
        id_proveedor_prod,
        id_alm        
	
	FROM ec_movimiento_detalle_proveedor_producto WHERE id_movimiento_detalle_proveedor_producto = id_mov_detalle_proveedor_prod;

SET query = (SELECT CONCAT(IFNULL(`id_movimiento_detalle_proveedor_producto`,0),',',IFNULL(`id_movimiento_almacen_detalle`,0),',',IFNULL(`id_proveedor_producto`,0),',',IFNULL(`cantidad`,0),',',IFNULL(`fecha_registro`,0),',',IFNULL(`id_sucursal`,0),',',IFNULL(`status_agrupacion`,0),',',IFNULL(`id_tipo_movimiento`,0),',',IFNULL(`id_almacen`,0),',',IFNULL(`id_pedido_validacion`,0),',',IFNULL(`folio_unico`,0),',',IFNULL(`sincronizar`,0),',',IFNULL(`insertado_por_sincronizacion`,0)) FROM `ec_movimiento_detalle_proveedor_producto` WHERE id_movimiento_detalle_proveedor_producto = id_mov_detalle_proveedor_prod );

    
    SELECT id_sucursal INTO store_id FROM sys_sucursales WHERE acceso=1;
	
	INSERT INTO sys_sincronizacion_registros_movimientos_proveedor_producto ( id_sincronizacion_registro, sucursal_de_cambio,
	id_sucursal_destino, datos_json, fecha, tipo, status_sincronizacion )
	SELECT 
	    NULL,
	    store_id,
	    id_sucursal,
	    CONCAT('{',
	        '"table_name" : "ec_movimiento_detalle_proveedor_producto",',
	        '"action_type" : "delete",',
	        '"primary_key" : "folio_unico",',
	        '"primary_key_value" : "', f_unico, '"',
	        '}'
	    ),
	    NOW(),
	    'eliminaMovimientoDetalleProveedorProducto',
	    1
	FROM sys_sucursales 
	WHERE id_sucursal = IF( store_id = -1, id_suc, -1 );

	SET final_inventory = ( ( cant * (SELECT afecta FROM ec_tipos_movimiento WHERE id_tipo_movimiento = id_tipo_mov ) ) );
	UPDATE ec_inventario_proveedor_producto SET inventario = ( inventario - final_inventory)
	WHERE id_proveedor_producto = id_proveedor_prod AND id_almacen = id_alm;

	DELETE FROM ec_movimiento_detalle_proveedor_producto WHERE id_movimiento_detalle_proveedor_producto = id_mov_detalle_proveedor_prod;

INSERT INTO ec_bitacora_movimiento_consulta (id_registro,nombre_tabla,id_pantalla_movimientos_almacen,id_tipo_consulta,regs_before )
VALUES (id_mov_detalle_proveedor_prod,'ec_movimiento_detalle_proveedor_producto',idpantalla,3,query);
END
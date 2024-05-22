DROP PROCEDURE IF EXISTS SpMovimientoAlmacenDetalle_elimina;
DELIMITER $$
create procedure SpMovimientoAlmacenDetalle_elimina (
 IN id_mov_almacen_detalle INT
,IN idpantalla INT) 
BEGIN
/*verificado 13-07-2023*/
  DECLARE store_id INT;   
  DECLARE id_almacen INT;    
  DECLARE tipo_afecta INT; 
  DECLARE origin_store_id INT;
  DECLARE id_mov INT;
  DECLARE cant float(15,4);
  DECLARE id_prod INT;
  DECLARE id_proveedor_prod INT;
  DECLARE f_unico varchar(30);
  DECLARE query VARCHAR(2500);

  SELECT id_movimiento,
  cantidad,
  id_producto,
  id_proveedor_producto,
  folio_unico 
  INTO 
  id_mov,
  cant,
  id_prod,
  id_proveedor_prod,
  f_unico
  FROM ec_movimiento_detalle 
  WHERE id_movimiento_almacen_detalle = id_mov_almacen_detalle;

SET query = (SELECT concat(IFNULL(`id_movimiento_almacen_detalle`,0),',',IFNULL(`id_movimiento`,0),',',IFNULL(`id_producto`,0),',',IFNULL(`cantidad`,0),',',IFNULL(`cantidad_surtida`,0),',',IFNULL(`id_pedido_detalle`,0),',',IFNULL(`id_oc_detalle`,0),',',IFNULL(`id_proveedor_producto`,0),',',IFNULL(`id_equivalente`,0),',',IFNULL(`folio_unico`,0),',',IFNULL(`sincronizar`,0),',',IFNULL(`insertado_por_sincronizacion`,0)) FROM `ec_movimiento_detalle` WHERE id_movimiento_almacen_detalle = id_mov_almacen_detalle );

  SELECT
  ma.id_almacen,
  tm.afecta,
  ma.id_sucursal
  INTO
  id_almacen,
  tipo_afecta,
  origin_store_id
  FROM ec_movimiento_almacen ma
  LEFT JOIN ec_tipos_movimiento tm 
  ON ma.id_tipo_movimiento=tm.id_tipo_movimiento
  WHERE ma.id_movimiento_almacen=id_mov;


  UPDATE ec_almacen_producto ap
  SET ap.inventario = ( ap.inventario - ( cant * tipo_afecta ) )
  WHERE ap.id_almacen = id_almacen 
  AND ap.id_producto = id_prod;


  IF( id_proveedor_prod != '' AND id_proveedor_prod IS NOT NULL AND id_proveedor_prod != -1 )
  THEN
  DELETE FROM ec_movimiento_detalle_proveedor_producto
  WHERE id_movimiento_almacen_detalle = id_movimiento_almacen_detalle
  AND id_proveedor_producto = id_proveedor_prod;
  END IF;
/*sincronizacion*/
  IF( f_unico IS NOT NULL )
  THEN
    SELECT id_sucursal INTO store_id FROM sys_sucursales WHERE acceso = 1;

    INSERT INTO sys_sincronizacion_registros_movimientos_almacen ( id_sincronizacion_registro, sucursal_de_cambio,
      id_sucursal_destino, datos_json, fecha, tipo, status_sincronizacion )
      SELECT 
        NULL,
        store_id,
        id_sucursal,
        CONCAT('{',
          '"table_name" : "ec_movimiento_detalle",',
          '"action_type" : "delete",',
          '"primary_key" : "folio_unico",',
          '"primary_key_value" : "', f_unico, '"',
          '}'
        ),
        NOW(),
        'eliminaMovimientoAlmacenDetalle',
        1
      FROM sys_sucursales 
      WHERE id_sucursal = IF( store_id = -1, origin_store_id, -1 );
  END IF;

DELETE FROM ec_movimiento_detalle WHERE id_movimiento_almacen_detalle = id_mov_almacen_detalle;

INSERT INTO ec_bitacora_movimiento_consulta (id_registro,nombre_tabla,id_pantalla_movimientos_almacen,id_tipo_consulta,regs_before )
VALUES (id_mov_almacen_detalle,'ec_movimiento_detalle',idpantalla,3,IFNULL(query,'No Existe el Regs'));

END
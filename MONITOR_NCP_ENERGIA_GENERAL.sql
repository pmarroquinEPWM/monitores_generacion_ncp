 # ==========================================================================================
DELIMITER //
CREATE PROCEDURE MONITOR_NCP_ENERGIA_GENERAL(
    IN param_fecha_inicio VARCHAR(20),
    IN param_fecha_fin VARCHAR(20)
)
BEGIN
SELECT A2.FECHA, A2.id_central,A2.GENERADOR,A2.TECNOLOGIA, A2.MW_REAL, IF(B2.MW_NCP IS NOT NULL, B2.MW_NCP, 0) AS 'MW_NCP',B2.NEXT_DAY, B2.ESCENARIO,  B2.version  FROM
    (SELECT FECHA, GENERADOR, SUM(POTENCIA_ACTIVA) MW_REAL , DIC.id_central, GDC.TECNOLOGIA FROM guatemala.GTM_CARGA_HORARIA A1,
                                                                                                 (select id_central, nemo from GTM_DICCIONARIO_CENTRALES
                                                                                                  union
                                                                                                  select id_central, nemo_ncp from GTM_DICCIONARIO_NCP) DIC,
                                                                                                 bi.GTM_DICCIONARIO_CENTRALES GDC
    WHERE FECHA BETWEEN param_fecha_inicio AND param_fecha_fin
        AND A1.GENERADOR = DIC.NEMO
        AND DIC.id_central = GDC.id_central
        GROUP BY DIC.id_central, A1.FECHA) A2
        LEFT JOIN
    (SELECT B1.ETAPA FECHA, SUM(MWH) MW_NCP, DIC.id_central, B1.NEXT_DAY, B1.ESCENARIO,  SIM.version FROM bi.GTM_CARGA_NCP B1,
                                                                                                       (select id_central, nemo_ncp AS NEMO from GTM_DICCIONARIO_NCP) DIC,
                                                                                                       (select id_simulacion,id_escenario,fecha, version from SIMULACIONES_NCP  WHERE FECHA BETWEEN param_fecha_inicio AND param_fecha_fin) SIM
    WHERE ETAPA BETWEEN param_fecha_inicio AND param_fecha_fin
        AND B1.NEMO = DIC.NEMO
        AND B1.id_simulacion = SIM.id_simulacion
    GROUP BY B1.ETAPA, DIC.id_central, B1.NEXT_DAY, B1.ESCENARIO,  SIM.version)  B2
ON A2.id_central = B2.id_central
AND A2.FECHA = B2.FECHA;
END //
DELIMITER ;
# ==========================================================================================
CALL MONITOR_NCP_ENERGIA_GENERAL('2022-12-01','2022-12-08')
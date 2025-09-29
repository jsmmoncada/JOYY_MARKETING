USE marketing;
/*/PREGUNTAS DE NEGOCIO/*/

/*/ CONSULTAS CLIENTES/*/
/*/1 . ¿Qué cliente obtuvo mayores ingresos (la eficiencia de la inversión ganancia respecto al gasto, no el monto bruto.) o ROI a través de su campaña publicitaria?*/
SELECT c.id_cliente, c.Nombre, c.apellido, MAX(cp.id_campana) AS id_campana, 
MAX(m.roi) AS max_roi
FROM Clientes AS c 
JOIN Campanas AS cp ON c.id_cliente = cp.id_cliente
JOIN metricas AS m ON m.id_campana = cp.id_campana
GROUP BY c.id_cliente, c.nombre, c.apellido
ORDER BY max_roi DESC
LIMIT 1;

/*/2. ¿Qué industria alcanzó las mejores tasas de conversión en sus campañas? /*/
SELECT c.industria,
ROUND(AVG(m.tasa_conversion_porcentaje), 2) AS promedio_tasa_conversion
FROM Clientes AS c
JOIN campanas AS cp ON c.id_cliente = cp.id_cliente
JOIN metricas AS m ON cp.id_campana = m.id_campana
GROUP BY c.industria
ORDER BY promedio_tasa_conversion DESC
LIMIT 3;


/*/ 3. ¿Cuál es la industria con mayor número de clientes activos en campañas actuales? /*/
SELECT c.industria,
COUNT(DISTINCT c.id_cliente) AS num_clientes_industria_en_campanas_activas
FROM Clientes AS c
JOIN Campanas AS cp ON c.id_cliente = cp.id_cliente
WHERE cp.estado_campaña = 1
GROUP BY c.industria
ORDER BY num_clientes_industria_en_campanas_activas DESC
LIMIT 1;

/*/ CONSULTAS EMPLEADOS/*/
/*/ 1. ¿Qué empleado, y con qué rol profesional, participó en un mayor número de campañas exitosas (demostrado por sus métricas de ROI)?/*/
SELECT CONCAT(e.nombre,' ', e.apellido) AS 'Nombre_completo', e.rol_profesional, AVG(m.roi) AS 'ROI_Promedio' FROM empleados e
JOIN dt_campanas_empleados d ON e.id_empleado = d.id_empleado 
JOIN campanas c ON d.id_campana = c.id_campana
JOIN metricas m ON m.id_campana = c.id_campana
ORDER BY AVG(m.roi);

SELECT 
    CONCAT(e.nombre, ' ', e.apellido) AS Nombre_completo,
    e.rol_profesional,
    COUNT(DISTINCT c.id_campana) AS Total_Campañas,
    AVG(m.roi) AS ROI_Promedio
FROM empleados e
JOIN dt_campanas_empleados d ON e.id_empleado = d.id_empleado
JOIN campanas c ON d.id_campana = c.id_campana
JOIN metricas m ON m.id_campana = c.id_campana
GROUP BY CONCAT(e.nombre, ' ', e.apellido), e.rol_profesional
HAVING ROI_Promedio > 1.5
ORDER BY ROI_Promedio DESC
LIMIT 10;

/*/ 2. ¿Qué empleados tienen mayor antigüedad y cómo influye este factor en el éxito de campañas activas?/*/
SELECT nombre, apellido FROM empleados
ORDER BY fecha_ingreso desc
LIMIT 10;

/*/ 3. ¿Cuál es el cargo o rol profesional con mayor número de empleados activos?/*/
SELECT cargo, COUNT(cargo) as Total_Empleados FROM empleados
WHERE activo = 1
GROUP BY cargo
ORDER BY Total_Empleados DESC;

SELECT rol_profesional, COUNT(cargo) as Total_Empleados FROM empleados
WHERE activo = 1
GROUP BY rol_profesional
ORDER BY Total_Empleados DESC;


/*/ CONSULTAS CAMPAÑAS/*/
/*/ 1. ¿Cuáles son las campañas con mayor presupuesto asignado?/*/
SELECT * FROM campanas;
SELECT 
	id_campana,
    nombre,
    presupuesto_usd
FROM CAMPANAS 
ORDER BY presupuesto_usd DESC
limit 10;

/*/ 2. ¿Qué tipos de objetivos publicitarios generan mejores métricas de conversión?/*/
SELECT 
    c.objetivo,
    SUM(m.numero_conversion) AS conversiones_totales,
    SUM(m.clics) AS clics_totales,
    AVG(m.tasa_conversion_porcentaje) AS tasa_conversion_promedio
FROM Campanas c
INNER JOIN Metricas m 
    ON c.id_campana = m.id_campana
GROUP BY c.objetivo
ORDER BY tasa_conversion_promedio DESC;

/*/ 3. ¿Cuál es la duración promedio de una campaña exitosa frente a una que no alcanzó sus objetivos?/*/
WITH CampanasClasificadas AS (
    SELECT 
        c.id_campana,
        AVG(m.roi) AS roi_promedio,
        DATEDIFF(c.fecha_fin, c.fecha_inicio) AS duracion_dias
    FROM Campanas c
    JOIN Metricas m 
        ON c.id_campana = m.id_campana
    WHERE c.fecha_inicio IS NOT NULL 
      AND c.fecha_fin IS NOT NULL
    GROUP BY c.id_campana, c.fecha_inicio, c.fecha_fin
)


SELECT 
    CASE 
        WHEN roi_promedio > 1.5 THEN 'Exitosa'
        ELSE 'No exitosa'
    END AS clasificacion_exito,
    ROUND(AVG(duracion_dias), 2) AS duracion_promedio_dias,
    COUNT(*) AS total_campanas
FROM CampanasClasificadas
GROUP BY 
    CASE 
        WHEN roi_promedio > 1.5 THEN 'Exitosa'
        ELSE 'No exitosa'
    END;


/*/4. ¿Qué campañas superaron su presupuesto estimado y cuál fue su ROI? /*/

SELECT 
    c.id_campana,
    c.nombre AS nombre_campana,
    c.presupuesto_usd AS presupuesto,
    SUM(m.ingreso) AS ingreso_total,
    (SUM(m.ingreso) - c.presupuesto_usd) AS excedente,
    ROUND((SUM(m.ingreso) - c.presupuesto_usd) / c.presupuesto_usd, 2) AS roi
FROM Campanas c
INNER JOIN Metricas m 
    ON c.id_campana = m.id_campana
GROUP BY c.id_campana, c.nombre, c.presupuesto_usd
HAVING SUM(m.ingreso) > c.presupuesto_usd 
ORDER BY roi DESC
LIMIT 10;

/*/5. ¿Qué públicos objetivos generan mejores resultados y cuáles reciben mayor presupuesto ?/*/ 
SELECT 
    c.publico_objetivo,
    ROUND(AVG(m.roi),2) AS roi_promedio,
    ROUND(AVG(m.tasa_conversion_porcentaje),2) AS tasa_conversion_promedio,
	SUM(m.numero_conversion) AS conversiones_totales,
    SUM(c.presupuesto_usd) AS presupuesto_total
FROM CAMPANAS c
JOIN METRICAS m ON c.id_campana = m.id_campana
GROUP BY c.publico_objetivo
ORDER BY roi_promedio DESC, presupuesto_total DESC;


/*/ 6. ¿Cuál ha sido la tendencia en el lanzamiento de campañas y cómo se correlaciona con el presupuesto promedio?/*/
 
/*/Tendencia Anual/*/
SELECT 
    YEAR(c.fecha_inicio) AS año,
    COUNT(c.id_campana) AS total_campañas,
    ROUND(AVG(c.presupuesto_usd),2) AS presupuesto_promedio
FROM CAMPANAS c
GROUP BY YEAR(c.fecha_inicio)
ORDER BY año;

/*/Para analizar la correlación: 
SQL NO PUEDE GENERAR GRÁFICOS, PERO ESTE RESULTADO SE PUEDE EXPORTAR A POWER BI Y
USARLO PARA GRAFICAR:
-Eje X: Año o (Mes/Año)
-Serie 1: Total de campañas (línea)
-Serie 2: Presupuesto promedio (línea o barra secundaria).

Eso te permite ver si, cuando se lanzan más campañas, el presupuesto promedio sube, baja o se mantiene.

-Más campañas = menor presupuesto promedio
Puede que cuando la agencia lanza muchas campañas, el presupuesto de cada una sea más bajo
(se reparten los recursos).

-Más campañas = mayor presupuesto promedio
Puede que en ciertos años la agencia crezca y aumente la inversión general.

-No hay correlación clara
Puede que el número de campañas no afecte el presupuesto promedio, lo cual también es un hallazgo
importante./*/

/*/ 7. ¿Qué clientes lanzan campañas de mayor duración y cuáles prefieren campañas cortas?/*/
SELECT 
    c.id_cliente,
    cl.nombre AS nombre_cliente,
    ROUND(AVG(DATEDIFF(c.fecha_fin, c.fecha_inicio)), 2) AS duracion_promedio_dias,
    MIN(DATEDIFF(c.fecha_fin, c.fecha_inicio)) AS duracion_minima_dias,
    MAX(DATEDIFF(c.fecha_fin, c.fecha_inicio)) AS duracion_maxima_dias,
    COUNT(c.id_campana) AS total_campanas
FROM Campanas c
JOIN Clientes cl 
    ON c.id_cliente = cl.id_cliente
WHERE c.fecha_inicio IS NOT NULL 
  AND c.fecha_fin IS NOT NULL
GROUP BY c.id_cliente, cl.nombre
ORDER BY duracion_promedio_dias DESC;


/*/CONSULTAS MÉTRICAS/*/
/*/ 1. ¿Cuál es el ROI promedio por cada campaña ejecutada en el último año y cuántas campañas presentaron un ROI negativo?*/
WITH roi_info AS (
    SELECT cp.id_campana,
	ROUND(AVG(m.roi), 2) AS roi_promedio,
	CASE
		WHEN SUM(CASE WHEN m.roi < 1.50 THEN 1 ELSE 0 END) > 0
		THEN 'Sí'
		ELSE 'No'
	END AS tuvo_roi_negativo
    FROM Campanas AS cp 
    JOIN metricas AS m ON cp.id_campana = m.id_campana
    WHERE cp.fecha_inicio >= CURDATE() - INTERVAL 1 YEAR
    GROUP BY cp.id_campana
)
SELECT *,
CASE 
	WHEN ROW_NUMBER() OVER (ORDER BY id_campana) = 1
	THEN (SELECT COUNT(*) FROM roi_info WHERE tuvo_roi_negativo = 'Sí')
	ELSE " "
END AS total_negativo
FROM roi_info;



/*2. ¿Qué campañas fueron más rentables en términos de ingresos y cuáles obtuvieron la mayor tasa de conversión?*/
SELECT cp.id_campana, cp.nombre AS nombre_campaña,
m.ingreso AS total_ingreso,
m.tasa_conversion_porcentaje AS tasa_conversion
FROM campanas cp
JOIN metricas m ON cp.id_campana = m.id_campana
ORDER BY m.ingreso DESC, m.tasa_conversion_porcentaje DESC
LIMIT 10;


 /*/ 3. ¿Qué campañas con bajo presupuesto lograron altos ingresos?/*/
SELECT cp.id_campana, cp.presupuesto_usd, m.ingreso
FROM campanas cp
JOIN metricas m ON cp.id_campana = m.id_campana
WHERE cp.presupuesto_usd <= 15000
AND m.ingreso >= 60000
ORDER BY cp.presupuesto_usd, m.ingreso DESC;


/*/ 4. ¿Qué campañas obtuvieron un alto alcance/clics pero baja tasa de conversión? /*/
SELECT cp.id_campana, m.alcance, m.clics, m.tasa_conversion_porcentaje
FROM campanas cp
JOIN metricas m ON cp.id_campana = m.id_campana
WHERE m.alcance >= 1000
AND m.clics >= 1100
AND m.tasa_conversion_porcentaje < 80
ORDER BY m.tasa_conversion_porcentaje ASC;


/*/ 5. ¿Qué relación existe entre el número de empleados asignados a una campaña y los resultados obtenidos en cada una?*/
SELECT cp.id_campana, cp.nombre AS nombre_campaña,
COUNT(DISTINCT dte.id_empleado) AS total_empleados,
m.id_metricas, m.ingreso, m.roi, m.tasa_conversion_porcentaje, m.alcance
FROM campanas cp
JOIN dt_campanas_empleados dte ON cp.id_campana = dte.id_campana
JOIN metricas m ON cp.id_campana = m.id_campana
GROUP BY cp.id_campana, cp.nombre, m.id_metricas, m.ingreso, m.roi, m.tasa_conversion_porcentaje, m.alcance
ORDER BY total_empleados DESC;

/*/CONSULTAS PLATAFORMAS/*/
/*/ 1. ¿Qué plataformas presentan mejor engagement promedio por campaña?/*/
SELECT nombre, engagement_promedio_porcentaje FROM plataformaS
ORDER BY engagement_promedio_porcentaje DESC;

/*/ 2. ¿Cuáles son las plataformas más efectivas en términos de alcance y número de conversiones?/*/
SELECT p.nombre, AVG(m.numero_conversion) AS 'Numero_conversion_promedio' FROM plataformas p
JOIN dt_campanas_plataformas d ON p.id_plataforma = d.id_plataforma 
JOIN campanas c ON d.id_campana = c.id_campana
JOIN metricas m ON m.id_campana = c.id_campana
GROUP BY p.nombre
ORDER BY AVG(m.numero_conversion) DESC;

/*/ 3. ¿Qué plataformas cuentan con mayor número de aliados activos en campañas?/*/
SELECT p.nombre, COUNT(a.activo) AS Total_Aliados_Activos FROM plataformas p
JOIN aliados a on p.id_plataforma = a.id_plataforma
WHERE a.activo = 1
GROUP BY p.nombre
ORDER BY Total_Aliados_Activos DESC
LIMIT 5;



/*/CONSULTAS ALIADOS/*/
/*/ 1. ¿Qué aliados, y a qué tipo de contenido pertenecen, tienen la mayor cantidad de seguidores y han participado en campañas con mejor engagement promedio?/*/
SELECT a.nombre, a.tipo, a.seguidores, m.clics FROM aliados a
JOIN dt_campanas_aliados d ON a.id_aliado = d.id_aliado 
JOIN campanas c ON d.id_campana = c.id_campana
JOIN metricas m ON m.id_campana = c.id_campana
ORDER BY m.clics DESC
LIMIT 10;

/*/ 2.¿Cuál es la relación entre el número de seguidores de un aliado y el ROI obtenido en campañas donde participa?/*/
SELECT a.nombre, a.seguidores, AVG(m.roi) AS 'ROI_Promedio' FROM aliados a
JOIN dt_campanas_aliados d ON a.id_aliado = d.id_aliado 
JOIN campanas c ON d.id_campana = c.id_campana
JOIN metricas m ON m.id_campana = c.id_campana
GROUP BY a.nombre, a.seguidores
HAVING AVG(m.roi) > 1.5
ORDER BY 'ROI_Promedio' DESC;

/*/ 3. ¿Qué aliado está presente en un mayor número de campañas activas?/*/
SELECT a.nombre, COUNT(c.estado_campana) AS Total_Campañas_Activas FROM aliados a
JOIN dt_campanas_aliados d ON a.id_aliado = d.id_aliado 
JOIN campanas c ON d.id_campana = c.id_campana
JOIN metricas m ON m.id_campana = c.id_campana
WHERE c.estado_campana = 1
GROUP BY a.nombre
ORDER BY Total_Campañas_Activas DESC
LIMIT 10;



/*/CONSULTAS SERVICIOS/*/

/*/1. ¿Qué servicio representa la mayor demanda dentro de las campañas, y cuál es el menos contratado?/*/
(
    SELECT 
        s.nombre AS servicio,
        COUNT(cs.id_campana) AS total_contratos
    FROM SERVICIOS s
    JOIN  DT_CAMPANAS_SERVICIOS cs ON s.id_servicio = cs.id_servicio
    GROUP BY s.nombre
    ORDER BY total_contratos DESC
    LIMIT 1
)
UNION ALL
(
    SELECT 
        s.nombre AS servicio,
        COUNT(cs.id_campana) AS total_contratos
    FROM SERVICIOS s
    JOIN  DT_CAMPANAS_SERVICIOS cs ON s.id_servicio = cs.id_servicio
    GROUP BY s.nombre
    ORDER BY total_contratos ASC
    LIMIT 1
);

/*/ 2. ¿Qué servicio tiene la tarifa más alta y ha sido utilizado en campañas con mayores ingresos?/*/
SELECT 
    s.id_servicio,
    s.nombre AS servicio,
    s.tarifa_usd,
    SUM(m.ingreso) AS ingresos_totales
FROM SERVICIOS s
JOIN DT_CAMPANAS_SERVICIOS cs ON s.id_servicio = cs.id_servicio
JOIN METRICAS m ON cs.id_campana = m.id_campana
WHERE s.tarifa_usd = (SELECT MAX(tarifa_usd) FROM SERVICIOS)
GROUP BY s.id_servicio, s.nombre, s.tarifa_usd
ORDER BY ingresos_totales DESC;


 /*/3. ¿Qué servicios han mostrado mejores resultados en determinadas plataformas, generando mayor engagement y ROI?/*/ 
 
 SELECT 
    s.nombre AS servicio,
    p.nombre AS plataforma,
    p.engagement_promedio_porcentaje,
    ROUND(AVG(m.roi),2) AS roi_promedio
FROM SERVICIOS s
JOIN DT_CAMPANAS_SERVICIOS cs ON s.id_servicio = cs.id_servicio
JOIN CAMPANAS c ON cs.id_campana = c.id_campana
JOIN DT_CAMPANAS_PLATAFORMAS cp ON c.id_campana = cp.id_campana
JOIN PLATAFORMAS p ON cp.id_plataforma = p.id_plataforma
JOIN METRICAS m ON c.id_campana = m.id_campana
GROUP BY s.nombre, p.nombre, p.engagement_promedio_porcentaje
ORDER BY roi_promedio DESC, p.engagement_promedio_porcentaje DESC;




 
 
 





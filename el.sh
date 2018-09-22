sqlplus -s srvgcorpbw/SRVGCORPBW@57.228.160.179:1333/lgec << EOF

set timing on
set termout off
set trimout on
#set arraysize 500
#SET PAGESIZE 50000
SET COLSEP "|"
#SET LINESIZE 200
set underline off
SET FEEDBACK OFF

spool data.out

select
    gcrtvp_mes_proceso mes_proceso,
    gcrtvp_cdg_centro_costo cdg_centro_costo,
    gcrtvp_cdg_clsf_gama cdg_clsf_gama,
    gcrtvp_cdg_orden cdg_orden,
    gcrtvp_cdg_sociedad_financiera cdg_sociedad_financiera,
    gcrtvp_cdg_subruta cdg_subruta,
    gcrtvp_fch_contable fch_contable,
    gcrtvp_nmr_cuenta nmr_cuenta,
    gcrtvp_tpo_material tpo_material,
    gcrtvp_tpo_registro tpo_registro,
    SUM(gcrtvp_MNT_USD_GESTION) MNT_USD_GESTION
from gcrtvp partition(A2018_M01)
    LEFT JOIN MAFB MAFB ON MAFB.MAFB_CDG_EPSILON = gcrtvp.gcrtvp_CDG_CLSF_GAMA
    AND MAFB.MAFB_CDG_DIVISION = gcrtvp.gcrtvp_CDG_NEGOCIO
    AND MAFB.MAFB_NMB_AUXILIAR = 'FABMIX_AUX_CEEX'
    AND MAFB.MAFB_MES_PROCESO = to_date('01-01-2013','dd-mm-yyyy')
    LEFT JOIN MCEEXC MCEEXC ON MCEEXC.MCEEXC_CDG = MAFB.MAFB_CDG_CEEX
where
    MCEEXC_CDG_NV1 = 'C2'
    and rownum <= 10000
group by
    gcrtvp_mes_proceso,
    gcrtvp_cdg_centro_costo,
    gcrtvp_cdg_clsf_gama,
    gcrtvp_cdg_orden,
    gcrtvp_cdg_sociedad_financiera,
    gcrtvp_cdg_subruta,
    gcrtvp_fch_contable,
    gcrtvp_nmr_cuenta,
    gcrtvp_tpo_material,
    gcrtvp_tpo_registro;

spool off
exit
EOF

#gsutil cp data.out gs://ltm-dl-lnd-arq-4602c262-7d08-49b9-b821-0c15bdc3ecb6
bash

rm(list=ls())

require(dplyr)
require(reshape)
require(reshape2)
require(stringr)

#modificamos la tabla para que cada fila sea un registro
melt.contaminacion <- melt(contaminacion, id = c("PROVINCIA","MUNICIPIO", "ESTACION","MAGNITUD","PUNTO_MUESTREO","ANO","MES"))

#creamos uno para los dias y otro para la señal de válido
v.contaminacion<-melt.contaminacion[grep("V", melt.contaminacion$variable), ]
d.contaminacion<-melt.contaminacion[grep("D", melt.contaminacion$variable), ]

#tengo que incluir un identificador de dia para poder unir ambos datasets
v.contaminacion$id<-sub('.*V', '', v.contaminacion$variable)
d.contaminacion$id<-sub('.*D', '', d.contaminacion$variable)

#ahora hacemos merge <3
merge.contaminacion<-merge(v.contaminacion,d.contaminacion, by=c("PROVINCIA", "MUNICIPIO","ESTACION", "MAGNITUD", "PUNTO_MUESTREO","ANO","MES","id"), all.x = T, all.y = F)

#...y creamos la fecha
merge.contaminacion$FECHA<-as.Date(with(merge.contaminacion, paste(ANO, MES, id,sep="-")), "%Y-%m-%d")
merge.contaminacion$CIUDAD<-'Madrid'

#lo ultimo sería eliminar los valores=N
merge.contaminacion <- merge.contaminacion[ which(merge.contaminacion$value.x=='V'), ]
#UNICAMENTE SON VÁLIDOS LOS DATOS QUE LLEVAN EL CÓDIGO DE VALIDACIÓN “V".
merge.contaminacion$VALOR<-merge.contaminacion$value.y
merge.contaminacion$MAGNITUD<-as.character(merge.contaminacion$MAGNITUD)

contaminacion.df<-merge.contaminacion %>%
  select('MAGNITUD','PUNTO_MUESTREO','VALOR','FECHA','CIUDAD') %>%
  filter(MAGNITUD %in% c('1','8','9','10','14'))


write.csv(contaminacion.df,file="contaminacion madrid dia.csv", row.names = F)


#reemplazamos estacion por la verdadera estacion
#merge.contaminacion$ESTACION<-as.character(sub('_.*', '', merge.contaminacion$PUNTO_MUESTREO))






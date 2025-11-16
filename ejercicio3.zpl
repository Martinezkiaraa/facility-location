###############################################################
#  MODELO DE PROGRAMACIÓN ENTERA – TP ACN
#  CONSIGNAS 1, 2 y 3 con restricciones adicionales:
#  - Conflictos de pares
#  - Conflictos de tríos (evitar 3 parciales el mismo día)
#  - Maximizar dispersión según pesos de estudiantes en común
#  - Evitar que parciales de cursos en conflicto queden:
#         (a) el mismo día
#         (b) en días consecutivos
###############################################################

#############################
# CONJUNTOS Y PARÁMETROS
#############################

# Cursos
set P := { read "cursos.dat" as "<1s>" };

# Días disponibles
set D := {1, 2, 3, 4, 5, 9, 10, 11, 12};

# Horarios disponibles por día
set T := {9, 12, 15, 18};

# Aulas necesarias por curso
param a[P] := read "cursos.dat" as "<1s> 2n";

# Capacidad total de aulas por slot (día, horario)
param A_S := 75;

# Pares de cursos con estudiantes en común
# E contiene las aristas del grafo de conflictos
set E := { read "estudiantes-en-comun.dat" as "<1s,2s>" };

# Peso: cantidad de estudiantes en común
param I[E] := read "estudiantes-en-comun.dat" as "<1s,2s> 3n";


###############################################
# TRÍOS COMPLETAMENTE INCOMPATIBLES (Consigna 2)
###############################################
# A = {p,q,r : todos los pares tienen conflicto}
set A := {
    <p,q,r> in P * P * P
    with p != q and p != r and q != r
         and <p,q> in E
         and <p,r> in E
         and <q,r> in E
};


#############################
# VARIABLES
#############################

# X[p,d,t] = 1 si el curso p rinde el día d en el horario t
var X[P * D * T] binary;

# Para Consigna 3: medir "cuán lejos" caen dos cursos en conflicto
# Z[p,q,d1,d2] = 1 si p está asignado al día d1 y q al día d2
var Z[E * D * D] binary;


#############################
# OBJETIVO – CONSIGNA 3
#############################
# Maximizar la "dispersión": penalizamos estar cerca y premiamos estar lejos.
# Peso = cantidad de estudiantes en común (I[p,q])
#
# Queremos dispersión → cuanto mayor la distancia |d1 - d2| mejor
# Si d1 = d2 → distancia = 0 → contribuye 0
# Si d1 y d2 lejos → contribuye más
#
# Objetivo:
#   max Σ I[p,q] * |d1 - d2| * Z[p,q,d1,d2]
#############################

maximize Dispersion:
    sum <p,q,d1,d2> in E * D * D:
        I[p,q] * abs(d1 - d2) * Z[p,q,d1,d2];


#############################
# RESTRICCIONES
#############################

###############
# Cada parcial se toma a lo sumo una vez
###############
subto UnSlot:
  forall <p> in P do
    sum <d,t> in D * T: X[p,d,t] <= 1;


###############
# Capacidad de aulas
###############
subto Capacidad:
  forall <d,t> in D * T do
    sum <p> in P: a[p] * X[p,d,t] <= A_S;


###############
# Conflicto estándar (consigna 1):
# dos cursos con estudiantes en común NO pueden rendir EN EL MISMO SLOT
###############
subto ConflictoSlot:
  forall <p,q> in E do
    forall <d,t> in D * T do
      X[p,d,t] + X[q,d,t] <= 1;


###############################
# Consigna 2 – evitar que los 3 cursos de un trío rindan el mismo día
###############################
subto TrioConflicto:
  forall <p,q,r> in A do
    forall <d> in D do
      (sum <t> in T: X[p,d,t])
    + (sum <t> in T: X[q,d,t])
    + (sum <t> in T: X[r,d,t]) <= 2;


###############################################################
# NUEVAS RESTRICCIONES PEDIDAS POR VOS:
# 1) No permitir que dos cursos en conflicto queden el mismo día.
# 2) No permitir que queden en días consecutivos.
###############################################################

###############
# 1. El MISMO DÍA prohibido
###############
subto NoMismoDia:
  forall <p,q> in E do
    forall <d> in D do
      (sum <t> in T: X[p,d,t])
    + (sum <t> in T: X[q,d,t]) <= 1;

set DC := {
    <1,2>, <2,3>, <3,4>, <4,5>,
    <9,10>, <10,11>, <11,12>
};

###############
# 2. DÍAS CONSECUTIVOS prohibidos
###############
subto NoConsecutivos_1:
  forall <p,q> in E do
    forall <d1,d2> in DC do
        (sum <t> in T: X[p,d1,t])
      + (sum <t> in T: X[q,d2,t]) <= 1;

subto NoConsecutivos_2:
  forall <p,q> in E do
    forall <d1,d2> in DC do
        (sum <t> in T: X[p,d2,t])
      + (sum <t> in T: X[q,d1,t]) <= 1;


###############################################################
# CONSIGNA 3 – Relación entre Z y X
#
# Z[p,q,d1,d2] = 1 <=> p está asignado al día d1 y q en d2
#
# Implementamos linealización:
###############################################################

subto LinkZ1:
  forall <p,q,d1,d2> in E * D * D do
    Z[p,q,d1,d2] <= sum <t> in T: X[p,d1,t];

subto LinkZ2:
  forall <p,q,d1,d2> in E * D * D do
    Z[p,q,d1,d2] <= sum <t> in T: X[q,d2,t];

subto LinkZ3:
  forall <p,q,d1,d2> in E * D * D do
    Z[p,q,d1,d2] >=
      (sum <t> in T: X[p,d1,t])
    + (sum <t> in T: X[q,d2,t]) - 1;

###############################################################
# FIN DEL MODELO
###############################################################
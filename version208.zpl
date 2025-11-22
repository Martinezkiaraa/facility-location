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

#############################
# VARIABLES
#############################

var X[P * D * T] binary;

var Z[E * D * D] binary;

#############################
# OBJETIVO – CONSIGNA 3 SIN RESTRICCIÓN DE DIA
#############################
maximize Dispersion: sum <p,q,d1,d2> in E * D * D: I[p,q] * abs(d1 - d2) * Z[p,q,d1,d2];

#############################
# RESTRICCIONES
#############################
param P_MAX := 208;
subto CantParcialesFijada:
    sum <p,d,t> in P * D * T: X[p,d,t] == P_MAX;
#OBLIGAMOS A ASIGNAR LOS 208 PARCIALES 

subto UnSlot:
    forall <p> in P do
        sum <d,t> in D*T: X[p,d,t] <= 1;

subto Capacidad:
    forall <d,t> in D*T do
        sum <p> in P: a[p] * X[p,d,t] <= A_S;

subto ConflictoOriginal:
  forall <p,q> in E do
    forall <d,t> in D*T do
        X[p,d,t] + X[q,d,t] <= 1;
#Ahora si pueden caer el mismo día en horarios distintos.

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
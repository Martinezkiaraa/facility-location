# ==========================
# Datos y conjuntos básicos
# ==========================

set P := { read "cursos.dat" as "<1s>" };
set D := {1, 2, 3, 4, 5, 9, 10, 11, 12};
set T := {9, 12, 15, 18};

# Aulas por curso (capacidad requerida por cada parcial)
param a[P] := read "cursos.dat" as "<1s> 2n";

# Aulas disponibles por slot (día, hora)
param A_S := 75;

# ==========================
# Grafo de incompatibilidades
# ==========================

# Conjunto de pares de cursos con estudiantes en común
set E := { read "estudiantes-en-comun.dat" as "<1s,2s>" };

# Tríos completamente incompatibles (triángulos del grafo)
set A := {
    <p,q,r> in P * P * P
    with
        p != q and p != r and q != r
        and <p,q> in E
        and <p,r> in E
        and <q,r> in E
};

# ==========================
# Variables
# ==========================

# X[p,d,t] = 1 si el parcial p se programa el día d a la hora t
var X[P * D * T] binary;

# Y[p,d] = 1 si el parcial p se programa el día d (en algún horario)
var Y[P * D] binary;

# ==========================
# Función objetivo
# ==========================

maximize parciales_asignados:
  sum <p,d,t> in P * D * T: X[p,d,t];

# ==========================
# Restricciones
# ==========================

# Cada parcial a lo sumo en un slot (día-hora)
subto UnSlot:
  forall <p> in P do
    sum <d,t> in D * T: X[p,d,t] <= 1;

# Capacidad de aulas por slot
subto Capacidad:
  forall <d,t> in D * T do
    sum <p> in P: a[p] * X[p,d,t] <= A_S;

# Conflicto por pares: dos cursos con estudiantes en común
# no pueden rendir en el mismo slot (día-hora)
subto Conflicto:
  forall <p,q> in E do
    forall <d,t> in D * T do
      X[p,d,t] + X[q,d,t] <= 1;

# Enlace entre X (slot) e Y (día):
# si p se programa en algún horario t del día d, Y[p,d] = 1
subto EnlaceY:
  forall <p,d,t> in P * D * T do
    X[p,d,t] <= Y[p,d];

# Tríos: no queremos que haya estudiantes rindiendo tres parciales
# de un triángulo del grafo el mismo día
subto TrioConflicto:
  forall <p,q,r> in A do
    forall <d> in D do
      Y[p,d] + Y[q,d] + Y[r,d] <= 2;
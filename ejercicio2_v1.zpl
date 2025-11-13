set P := { read "cursos.dat" as "<1s>" };
set D := {1, 2, 3, 4, 5, 9, 10, 11, 12};
set T := {9, 12, 15, 18};

# Aulas por curso
param a[P] := read "cursos.dat" as "<1s> 2n";

# Aulas disponibles por slot
param A_S := 75;

# Conjunto de pares incompatibles
set E := { read "estudiantes-en-comun.dat" as "<1s,2s>" };
param I[E] := read "estudiantes-en-comun.dat" as "<1s,2s> 3n";

# Tríos completamente incompatibles (todos los pares tienen estudiantes en común)
set A := {
    <p,q,r> in P * P * P
    with
        p != q and p != r and q != r
        and <p,q> in E
        and <p,r> in E
        and <q,r> in E
};

var X[P * D * T] binary;

maximize parciales_asignados:
  sum <p,d,t> in P*D*T: X[p,d,t];

subto UnSlot:
  forall <p> in P do
    sum <d,t> in D*T: X[p,d,t] <= 1;

subto Capacidad:
  forall <d,t> in D*T do
    sum <p> in P: a[p] * X[p,d,t] <= A_S;

subto Conflicto:
  forall <p,q> in E do
    forall <d,t> in D*T do
      X[p,d,t] + X[q,d,t] <= 1;

subto TrioConflicto:
  forall <p,q,r> in A do
    forall <d> in D do
      (sum <t> in T: X[p,d,t])
    + (sum <t> in T: X[q,d,t])
    + (sum <t> in T: X[r,d,t]) <= 2;
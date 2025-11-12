# estudiantes-en-comun.dat: <p> <q> <w_pq>
set Eraw := { read "estudiantes-en-comun.dat" as "<1n,2n>" skip 1 };
set E    := { <p,q> in Eraw : p < q };                  # evitar duplicados
param w[E] := read "estudiantes-en-comun.dat"
              as "<1n,2n> <3n>" skip 1;                 # (no se usa en Cons.1, pero queda cargado)
---------------------------------------------

set P := {read "cursos.dat" as "<1n>" skip 1};
set D := {1, 2, 3, 4, 5, 9, 10, 11, 12};
set T := {9, 12, 15, 18};

# Conjunto de slots
set S := D cross T;     # slots s = <d,t>

#Aulas por curso
param a[P] := read "curso.dat" as "<1n> <2n>" skip 1;

#Aulas disponibles por slot
param A_S := 75;

#Conjunto de pares incompatibles
set E := {read "estudiantes-en-comun.dat" as "<1n,2n>" skip 1};
param I[E] := read "estudiantes-en-comun.dat" as "<1n,2n> <3n>" skip 1;

# Variable indicadora X_p_s: X[p,s] = 1 si el parcial p se programa en el slot s=(d,t), 0 en caso contrario.
var X[P*S] binary;

#Función objetivo
maximize parciales_asignados: sum <p,s> in P*S: X[p,s];

#Restricciones
subto UnSlot: forall <p> in P do sum <s> in S: X[p,s] <= 1;
subto Capacidad: forall <s> in S do sum <p> in P: a[p] * X[p,s] <= A_S[ord(s,1), ord(s,2)];
subto Conflicto: forall <(p,q)> in E do forall <s> in S do X[p,s] + X[q,s] <= 1;
subto Dominio: forall <p> in P, <s> in S do X[p,s] in {0,1};  #No hace falta, por claridad



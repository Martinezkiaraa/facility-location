set P := {read "cursos.dat" as "<1s>"};
set D := {1, 2, 3, 4, 5, 9, 10, 11, 12};
set T := {9, 12, 15, 18};

#Aulas por curso
param a[P] := read "cursos.dat" as "<1s> 2n";

#Aulas disponibles por slot
param A_S := 75;

#Conjunto de pares incompatibles
set E := {read "estudiantes-en-comun.dat" as "<1s,2s>"};
param I[E] := read "estudiantes-en-comun.dat" as "<1s,2s> 3n";

# Variable indicadora X_p_s: X[p,s] = 1 si el parcial p se programa en el slot s=(d,t), 0 en caso contrario.
var X[P * D * T] binary;

#Función objetivo
maximize parciales_asignados: sum <p,d,t> in P*D*T: X[p,d,t];

#Restricciones
subto UnSlot: forall <p> in P do sum <d,t> in D*T: X[p,d,t] <= 1;
subto Capacidad: forall <d,t> in D*T do sum <p> in P: a[p] * X[p,d,t] <= A_S;
subto Conflicto: forall <p,q> in E do forall <d,t> in D*T do X[p,d,t] + X[q,d,t] <= 1;
subto Dominio: forall <p,d,t> in P * D * T do X[p,d,t] >= 0 and X[p,d,t] <= 1; #No hace falta
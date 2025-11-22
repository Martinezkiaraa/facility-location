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

# pares de días consecutivos en el calendario efectivo
set ADJ := {
  <1,2>, <2,3>, <3,4>, <4,5>,
  <9,10>, <10,11>, <11,12>
};

var Yadj[E*ADJ] binary; 
# Yadj[p,q,(d1,d2)] = 1 si p en d1 y q en d2

# w[p,q] = cantidad de estudiantes en común entre p y q
param w[E] := read "estudiantes-en-comun.dat" as "<1s,2s> 3n";

var X[P*D*T] binary;
var Z[P*D] binary;

subto AsignacionUnica:
  forall <p> in P do
    sum <d> in D do
      sum <t> in T: X[p,d,t] == 1;


subto ConflictoPares:
  forall <p,q> in E do
    forall <d> in D do
      Z[p,d] + Z[q,d] <= 1;

subto ConflictoParesAdyacentes:
  forall <p,q> in E do
    forall <d1,d2> in ADJ do
      Z[p,d1] + Z[q,d2] <= 1;

subto EvitarTrios:
  forall <d> in D do
    sum <p> in P: Z[p,d] <= 2;

minimize JuntosConPeso:
  sum <p,q> in E do
    sum <d1,d2> in ADJ:
      w[p,q] * Yadj[p,q,d1,d2];

#Si p está en algún turno de ese día → la suma vale 1 → Z[p,d] = 1
#Si no está en ningún turno → suma 0 → Z[p,d] = 0

subto Enlace_ZX:
  forall <p> in P do
    forall <d> in D do
      sum <t> in T: X[p,d,t] == Z[p,d];

subto Link_Yadj_le_p:
  forall <p,q> in E do
    forall <d1,d2> in ADJ do
      Yadj[p,q,d1,d2] <= Z[p,d1];

subto Link_Yadj_le_q:
  forall <p,q> in E do
    forall <d1,d2> in ADJ do
      Yadj[p,q,d1,d2] <= Z[q,d2];

subto Link_Yadj_ge:
  forall <p,q> in E do
    forall <d1,d2> in ADJ do
      Yadj[p,q,d1,d2] >= Z[p,d1] + Z[q,d2] - 1;






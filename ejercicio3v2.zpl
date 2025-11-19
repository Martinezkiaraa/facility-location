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

# pares de días consecutivos en el calendario efectivo
set ADJ := {
  <1,2>, <2,3>, <3,4>, <4,5>,
  <9,10>, <10,11>, <11,12>
};

# w[p,q] = cantidad de estudiantes en común entre p y q
param w[E] := read "estudiantes-en-comun.dat" as "<1s,2s> 3n";

var X[P*D*T] binary;
var Z[P*D] binary;   #Si p está en algún turno de ese día → la suma vale 1 → Z[p,d] = 1
                     #Si no está en ningún turno → suma 0 → Z[p,d] = 0

minimize JuntosConPeso:
  sum <p,q,d1,d2> in E * ADJ:
    w[p,q] * Yadj[p,q,d1,d2];

subto UnSlot:
  forall <p> in P do
    sum <d,t> in D * T: X[p,d,t] <= 1;

subto Enlace_ZX:
  forall <p> in P do
    forall <d> in D do
      sum <t> in T: X[p,d,t] == Z[p,d];

var Yadj[E*ADJ] binary;   # Yadj[p,q,(d1,d2)] = 1 si p en d1 y q en d2

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
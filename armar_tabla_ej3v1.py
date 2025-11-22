import csv

# ==== CONFIGURACIÓN DE ARCHIVOS ====
SOL_FILE = "solucion3v1.txt"
CURSOS_FILE = "cursos.dat"
CSV_OUT = "tabla_ejercicio3v1.csv"

# 1) Leer los códigos de cursos en el mismo orden que ZIMPL
cursos = []
with open(CURSOS_FILE, "r") as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        cursos.append(parts[0])

# 2) Leer la solución de SCIP y extraer las X[p,d,t] = 1
asignaciones = []

with open(SOL_FILE, "r") as f:
    for line in f:
        line = line.strip()
        # Las filas de variables empiezan con "X$"
        if not line.startswith("X$"):
            continue

        tokens = line.split()
        # tokens[0] = nombre de variable, tokens[1] = valor (debería ser 1)
        if len(tokens) < 2 or tokens[1] != "1":
            continue

        # Ejemplo de tokens[0]: "X$P0#1#9"
        var = tokens[0][2:]  # sacar "X$" -> "P0#1#9"
        p_str, d_str, t_str = var.split("#")  # ["P0","1","9"]

        # P0 -> índice 0 -> primer curso en cursos.dat
        idx = int(p_str[1:])  # sacar la "P" y convertir a int
        curso = cursos[idx] if idx < len(cursos) else p_str

        dia = int(d_str)
        hora = int(t_str)

        asignaciones.append((curso, dia, hora))

# 3) Ordenar la tabla por día, hora, curso
asignaciones.sort(key=lambda r: (r[1], r[2], r[0]))

# 4) Guardar como CSV
with open(CSV_OUT, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["curso", "dia", "hora"])
    writer.writerows(asignaciones)

# 5) Imprimir también una tabla en Markdown (para pegar en el informe)
print("| Curso | Día | Hora |")
print("|-------|-----|------|")
for curso, dia, hora in asignaciones:
    print(f"| {curso} | {dia} | {hora} |")

print(f"\nSe generó el archivo '{CSV_OUT}' con {len(asignaciones)} filas.")
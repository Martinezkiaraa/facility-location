import pandas as pd
import matplotlib.pyplot as plt

# === Cargar soluciones de las dos versiones del Ejercicio 3 ===
df_v1 = pd.read_csv("tabla_ejercicio3v1.csv")
df_v2 = pd.read_csv("tabla_ejercicio3v2.csv")

# Esperamos columnas: curso,dia,hora
print(df_v1.head())
print(df_v2.head())

# === Contar parciales por día en cada versión ===
counts_v1 = df_v1.groupby("dia").size().rename("Versión 1")
counts_v2 = df_v2.groupby("dia").size().rename("Versión 2")

# === Armar tabla resumen ===
days = sorted(set(counts_v1.index).union(counts_v2.index))

summary_3 = pd.DataFrame(index=days)
summary_3["Versión 1"] = counts_v1
summary_3["Versión 2"] = counts_v2
summary_3 = summary_3.fillna(0).astype(int)

print("\nCantidad de parciales por día (Ejercicio 3):")
print(summary_3)

# === Gráfico comparativo ===
fig, ax = plt.subplots(figsize=(8,5))

x = range(len(summary_3.index))
width = 0.35

ax.bar([i - width/2 for i in x], summary_3["Versión 1"], width, label="Versión 1")
ax.bar([i + width/2 for i in x], summary_3["Versión 2"], width, label="Versión 2")

ax.set_xticks(list(x))
ax.set_xticklabels(summary_3.index)
ax.set_xlabel("Día")
ax.set_ylabel("Cantidad de parciales")
ax.set_title("Ejercicio 3: comparación de parciales por día (Versión 1 vs Versión 2)")
ax.legend()
ax.grid(True, axis="y")

plt.tight_layout()
plt.show()
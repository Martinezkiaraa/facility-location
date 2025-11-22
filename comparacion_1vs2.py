import pandas as pd
import matplotlib.pyplot as plt

# === Cargar tus archivos reales ===
df1 = pd.read_csv("tabla_ejercicio1.csv")
df2 = pd.read_csv("tabla_ejercicio2.csv")

# === Agrupar por día ===
counts1 = df1.groupby("dia").size().rename("Consigna 1")
counts2 = df2.groupby("dia").size().rename("Consigna 2")

# === Tabla comparativa ===
days = sorted(set(counts1.index).union(counts2.index))

summary = pd.DataFrame(index=days)
summary["Consigna 1"] = counts1
summary["Consigna 2"] = counts2
summary = summary.fillna(0).astype(int)

print(summary)

# === Gráfico comparativo ===
fig, ax = plt.subplots(figsize=(8,5))

x = range(len(summary.index))
width = 0.35

ax.bar([i - width/2 for i in x], summary["Consigna 1"], width, label="Consigna 1")
ax.bar([i + width/2 for i in x], summary["Consigna 2"], width, label="Consigna 2")

ax.set_xticks(list(x))
ax.set_xticklabels(summary.index)
ax.set_xlabel("Día")
ax.set_ylabel("Cantidad de parciales")
ax.set_title("Parciales programados por día: comparación Consigna 1 vs Consigna 2")
ax.legend()
ax.grid(True, axis="y")

plt.tight_layout()
plt.show()
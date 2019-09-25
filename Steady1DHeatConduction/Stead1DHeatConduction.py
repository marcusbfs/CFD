# Bibliotecas
import numpy as np
import matplotlib.pyplot as plt
import numba
from scipy.interpolate import griddata


class SteadyHeatConduction1DWithUniformSource:
    def __init__(self, L=0.5, k=1, S=0.0):
        self.setupExample()
        self.DotColor = "yellow"
        self.LineColor = "red"

    def setupExample(self):
        self.L = 0.5  # Comprimento da barra, metros
        self.k = 1  # Condutividade térmica, W/m.K
        self.S = 0.0  # Termo fonte, W/m^3
        self.N = 7  # Número de pontos

        self.TA = 100  # Temperatura no começo da barra, ºC
        self.TB = 500  # Temperatura no final da barra, ºC
        self._updateAll()

    def setPointsNumber(self, N: int):
        self.N = N

    def setPointsDistance(self, l: float):
        self.N = int(self.L / l)

    def setLength(self, L: float):
        self.L = L

    def setK(self, k: float):
        self.k = k

    def setSource(self, S: float):
        self.S = S

    def setBoundaryConditions(self, TA, TB):
        self.TA = TA
        self.TB = TB

    def solve(self):
        self._updateAll()
        self.T = _finite_volume_ex(
            self.x, self.a, self.b, self.c, self.d, self.TA, self.TB, self.S, self.k
        )

    def solveAndPlot1D(self):
        self.solve()
        self.plot1D()

    def solveAndPlot2D(self):
        self.solve()
        self.plot2D()

    def setDotColor(self, c: str):
        self.DotColor = c

    def setLineColor(self, c: str):
        self.LineColor = c

    def getT(self):
        return self.T

    def plot1DEx(self):
        self.setupExample()
        self.solve()
        self.plot1D(True)

    def plot2D(self, W: float = 1.0, nw: int = 10):
        # Cria plano quadrado
        w = np.linspace(0, W, nw)
        X, Y = np.meshgrid(self.x, w)
        Z = np.zeros(np.shape(X))

        for i in range(nw):
            Z[i, :] = self.T[:]

        fig, ax = plt.subplots()

        c = ax.pcolormesh(
            X, Y, Z, cmap="RdBu", vmin=np.min(self.T), vmax=np.max(self.T)
        )
        ax.axis([self.x.min(), self.x.max(), w.min(), w.max()])
        fig.colorbar(c, ax=ax)
        plt.show()

    def plot1D(self, plotExAnalytic=False):
        fig, ax = plt.subplots()

        n_func = 100
        n = self.N

        x_analitic = np.linspace(0, self.L, n_func)
        T_analitic = self._AnalyticExFunc(x_analitic)

        if plotExAnalytic:
            # Plot 1d - Comparar com solução analítica
            ax.plot(
                x_analitic,
                T_analitic,
                "k--",
                label="Solução analítica",
                color=self.LineColor,
            )
            ax.set_title("Comparação com solução analítica")

        ax.plot(
            self.x,
            self.T,
            "bo",
            markerfacecolor=self.DotColor,
            label="Volumes Finitos ({} pontos)".format(n),
            linewidth=2.5,
        )
        ax.set_xlabel("Posição [m]")
        ax.set_ylabel("T [ºC]")
        ax.grid()
        ax.legend()

        # Plot 2d
        plt.show()

    def _updateAll(self):
        self._updateArrays()
        self._updateBoundaryConditions()

    def _updateBoundaryConditions(self):
        n = self.N
        self.a[0] = 1.0
        self.a[n - 1] = 1.0
        self.b[0] = 0.0
        self.b[n - 1] = 0.0
        self.c[0] = 0.0
        self.c[n - 1] = 0.0
        self.d[0] = self.TA
        self.d[n - 1] = self.TB

    def _updateArrays(self):
        self.x = np.linspace(
            0, self.L, self.N, dtype=np.float64
        )  # posições igualmente espaçadas
        self.a = np.zeros(self.N, dtype=np.float64)
        self.b = np.zeros(self.N, dtype=np.float64)
        self.c = np.zeros(self.N, dtype=np.float64)
        self.d = np.zeros(self.N, dtype=np.float64)
        self.T = np.zeros(self.N, dtype=np.float64)

    def _AnalyticExFunc(self, x: float):
        return 100 + 800 * x


# ================================================================= #


@numba.njit(
    numba.float64[:](
        numba.float64[:],
        numba.float64[:],
        numba.float64[:],
        numba.float64[:],
        numba.float64[:],
        numba.float64,
        numba.float64,
        numba.float64,
        numba.float64,
    )
)
def _finite_volume_ex(x, a, b, c, d, TA, TB, S, k):

    n = len(a)

    P = np.zeros(n, dtype=np.float64)
    Q = np.zeros(n, dtype=np.float64)
    T = np.zeros(n, dtype=np.float64)

    P[0] = 0.0
    Q[0] = TA
    T[0] = TA
    T[n - 1] = TB

    # Preenchendo aP, aE e aW - inclui malhas não uniformes
    for i in range(1, n - 1):
        delta_x_W = x[i] - x[i - 1]
        delta_x_E = x[i + 1] - x[i]
        b[i] = 1.0 / delta_x_E
        c[i] = 1.0 / delta_x_W
        a[i] = b[i] + c[i]
        d[i] = S * 0.5 * (delta_x_E + delta_x_W) / k

    # Looping para P e Q
    for i in range(1, n):
        den = a[i] - c[i] * P[i - 1]
        P[i] = b[i] / den
        Q[i] = (Q[i - 1] * c[i] + d[i]) / den

    # Looping reverso para a temperatura
    for i in range(n - 2, 0, -1):
        T[i] = P[i] * T[i + 1] + Q[i]

    # Retorna as temperaturas calculadas nos pontos
    return T


if __name__ == "__main__":
    m = SteadyHeatConduction1DWithUniformSource()
    m.plot1DEx()
    m.setPointsNumber(100)
    m.solveAndPlot2D()

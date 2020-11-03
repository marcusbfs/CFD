# Bibliotecas
import numpy as np
import matplotlib.pyplot as plt
import numba
from fmodel import fmodel
import time
import timeit


class SteadyHeatConduction1DWithUniformSource:
    def __init__(self, L=0.5, k=1, S=0.0):
        self.setupExample()
        self.DotColor = "yellow"
        self.LineColor = "red"
        self.use_fotran = False

    def setupExample(self):
        self.L = 0.5  # Comprimento da barra, metros
        self.k = 1  # Condutividade térmica, W/m.K
        self.S = 0.0  # Termo fonte, W/m^3
        self.N = 7  # Número de pontos
        self.setPointsNumber(self.N)

        self.TA = 100  # Temperatura no começo da barra, ºC
        self.TB = 500  # Temperatura no final da barra, ºC
        self._updateAll()

    def setPointsNumber(self, N: int):
        self.N = N

    def setPointsDistance(self, l: float):
        self.N = int(self.L / l)
        self.x = np.linspace(
            0, self.L, self.N, dtype=np.float64
        )  # posições igualmente espaçadas

    def setX(self, x):
        self.x = np.asarray(x)
        self.N = len(x)

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
        if self.use_fotran:
            self.solveFortran()
            return

        self._updateAll()
        self.T = _finite_volume_ex(
            0.0, self.L, self.TA, self.TB, self.S, self.k, self.N
        )

    def solveFortran(self):
        self.T = fmodel.finite_volume_example(0.0, self.L, self.TA, self.TB, self.S, self.k, self.N)


    def setUseFortran(self, useFortran : bool) -> None:
        self.use_fotran = useFortran

    def solveAndPlot1D(self, A=True):
        self.solve()
        self.plot1D(A)

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

    def plot1D(self, plotExAnalytic=True):
        self._updateXArray()
        fig, ax = plt.subplots()
        self._create1Dplot(fig, ax, plotExAnalytic)

        # Plot 2d
        plt.show()

    def plot2D(self, W: float = 1.0, nw: int = 10):
        # Cria plano quadrado
        w = np.linspace(0, W, nw)
        X, Y = np.meshgrid(self.x, w)
        Z = np.zeros(np.shape(X))

        for i in range(nw):
            Z[i, :] = self.T[:]

        fig, ax = plt.subplots()
        self._create2Dplot(fig, ax, X, Y, Z, w)
        plt.show()

    def plot1DAnd2D(self, W: float = 1.0, nw: int = 10):
        fig, axes = plt.subplots(2)
        self._create1Dplot(fig, axes[0], False)

        w = np.linspace(0, W, nw)
        X, Y = np.meshgrid(self.x, w)
        Z = np.zeros(np.shape(X))

        for i in range(nw):
            Z[i, :] = self.T[:]

        self._create2Dplot(fig, axes[1], X, Y, Z, w)

        for ax in axes:
            ax.set_ylim(self.x.min(), self.x.max())

        plt.show()

    def _create2Dplot(self, fig, ax, X, Y, Z, w):

        c = ax.pcolormesh(
            X, Y, Z, cmap="RdBu", vmin=np.min(self.T), vmax=np.max(self.T)
        )
        ax.axis([self.x.min(), self.x.max(), w.min(), w.max()])
        fig.colorbar(c, ax=ax)

    def _create1Dplot(self, fig, ax, plotA):

        n_func = 100
        n = self.N

        if plotA:
            # Plot 1d - Comparar com solução analítica
            x_analitic = np.linspace(0, self.L, n_func)
            T_analitic = self._AnalyticExFunc(x_analitic)
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

    def _updateXArray(self):
        self.x = np.linspace(
            0, self.L, int(self.N), dtype=np.float64
        )  # posições igualmente espaçadas

    def _updateArrays(self):
        self._updateXArray()
        self.a = np.zeros(int(self.N), dtype=np.float64)
        self.b = np.zeros(int(self.N), dtype=np.float64)
        self.c = np.zeros(int(self.N), dtype=np.float64)
        self.d = np.zeros(int(self.N), dtype=np.float64)
        self.T = np.zeros(int(self.N), dtype=np.float64)

    def _AnalyticExFunc(self, x: float):
        C1 = (self.TB - self.TA + self.S * self.L ** 2 * 0.5 / self.k) / self.L
        return -self.S * x ** 2 * 0.5 / self.k + C1 * x + self.TA


# ================================================================= #


@numba.njit(
    numba.float64[:](
        numba.float64,
        numba.float64,
        numba.float64,
        numba.float64,
        numba.float64,
        numba.float64,
        numba.int64,
    )
)
def _finite_volume_ex(x1, x2, TA, TB, S, k, n):

    P = np.zeros(n, dtype=np.float64)
    Q = np.zeros(n, dtype=np.float64)
    T = np.zeros(n, dtype=np.float64)

    delta = (x2 - x1) /float(n-1)
    b = np.full(n, 1.0/delta, dtype=np.float64)
    a = b + b

    # boundaries
    a[0] = 1.
    a[n-1] = 1.
    b[0] = 0.
    b[n-1] = 0.
    T[0] = TA
    T[n-1] = TB
    Q[0] = TA
    P[0] = 0.

    d = np.full(n, S* 0.5 *(delta + delta) / k, dtype=np.float64)
    d[0] = TA
    d[n-1] = TB

    # Looping para P e Q
    for i in range(1, n):
        inv_den = 1.0 / ( a[i] - b[i] * P[i - 1])
        P[i] = b[i] * inv_den
        Q[i] = (Q[i - 1] * b[i] + d[i]) * inv_den

    # Looping reverso para a temperatura
    for i in range(n - 2, 0, -1):
        T[i] = P[i] * T[i + 1] + Q[i]

    # Retorna as temperaturas calculadas nos pontos
    return T


if __name__ == "__main__":
    m = SteadyHeatConduction1DWithUniformSource()
    n = 1.4e7

    n = int(n)
    print("n = ", n)
    m.setPointsNumber(n)

    print("Solve")
    t0 = time.time()
    m.solve()
    t1 = time.time()
    t_for = t1-t0
    print("Time = {:.10f} ms".format(1e3*(t_for)))

    print("Solve Fortran")
    t0 = time.time()
    m.solveFortran()
    t1 = time.time()
    t_for = t1-t0

    print("Time = {:.10f} ms".format(1e3*(t_for)))

    #m.plot1D()

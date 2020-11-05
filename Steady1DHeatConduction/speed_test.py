
import numpy as np
import time
from model import SteadyHeatConduction1DWithUniformSource

nruns = 1e3
n = 1.4e4

n = int(n)
nruns = int(nruns)
print("n runs = {:.3E}".format(nruns))
print("n = {:.3E}".format(n))
print("")

m = SteadyHeatConduction1DWithUniformSource()
m.setPointsNumber(n)

time_solve = []
time_totalA = time.time()
for j in range(nruns):
    time_A = time.time()
    m.solve()
    time_solve.append(time.time() - time_A)

time_total_solve = (time.time() - time_totalA) * 1e3
time_solve_mean = np.mean(time_solve) * 1e3
time_solve_std = np.std(time_solve) * 1e3
print("Solve")
print("Time (mean) [ms] = {:.10f} +- {:.10f}".format(time_solve_mean, time_solve_std))
print("Total time [ms] = {:.10f}".format(time_total_solve))
print("")

# Fotran v1
time_solve = []
time_totalA = time.time()
for j in range(nruns):
    time_A = time.time()
    m.solveFortran()
    time_solve.append(time.time() - time_A)

time_total_solve = (time.time() - time_totalA) * 1e3
time_solve_mean = np.mean(time_solve) * 1e3
time_solve_std = np.std(time_solve) * 1e3
print("Solve Fortran")
print("Time (mean) [ms] = {:.10f} +- {:.10f}".format(time_solve_mean, time_solve_std))
print("Total time [ms] = {:.10f}".format(time_total_solve))
print("")

# Fotran v2
time_solve = []
time_totalA = time.time()
for j in range(nruns):
    time_A = time.time()
    m.solveFortranV2()
    time_solve.append(time.time() - time_A)

time_total_solve = (time.time() - time_totalA) * 1e3
time_solve_mean = np.mean(time_solve) * 1e3
time_solve_std = np.std(time_solve) * 1e3
print("Solve Fortran V2")
print("Time (mean) [ms] = {:.10f} +- {:.10f}".format(time_solve_mean, time_solve_std))
print("Total time [ms] = {:.10f}".format(time_total_solve))
print("")
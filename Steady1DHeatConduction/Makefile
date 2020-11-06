venv = cfd_venv/Scripts/activate.bat
fortran_flags += -Ofast -funroll-loops
f2py_cmd += python -m numpy.f2py -c types.f90 fmodel.f90 -m fmodel --opt="${fortran_flags}"
FC = gfortran
tester_exe = tester.exe


.PHONY: clean

all: f2py

f2py: types.f90 fmodel.f90
	${f2py_cmd} && make move_dll && make rm_dir

test: tester.o fmodel.o tester.o
	${FC} types.o fmodel.o tester.o -o ${tester_exe} ${fortran_flags}

tester.o : tester.f90 types.o fmodel.o
	gfortran ${fortran_flags} -c tester.f90

types.o : types.f90
	gfortran ${fortran_flags} -c types.f90

fmodel.o : fmodel.f90 types.o
	gfortran ${fortran_flags} -c fmodel.f90

cleanall : clean rm_dir
	rm -rf tester.o ${tester_exe} fmodel.cp* *.dll

move_dll:
	mv fmodel/.libs/* .

rm_dir:
	rm -rf fmodel/

clean:
	rm -rf *.o *.mod
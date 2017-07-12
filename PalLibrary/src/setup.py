from distutils.core import setup, Extension
from Cython.Build import cythonize

setup(ext_modules = cythonize(Extension(
           "yj1",
           sources=["yj1.pyx", "yj1.cpp"],
           language="c++",
      )))
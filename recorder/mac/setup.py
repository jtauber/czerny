
from distutils.core import setup
from distutils.extension import Extension
from Pyrex.Distutils import build_ext

setup(
    name = 'midi',
    ext_modules=[
    Extension("CoreMIDI",       ["CoreMIDI.pyx"],
              extra_link_args = ['-framework', 'CoreFoundation',
                                 '-framework', 'CoreMIDI']),
    ],
    cmdclass = {'build_ext': build_ext}
)

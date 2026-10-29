# ubuntu-occt-cgal-eigen-node

![Build Status](https://github.com/Michsior14/docker-3d-tools/actions/workflows/build-and-publish.yml/badge.svg)

Docker image of ubuntu with [opencascade](https://git.dev.opencascade.org/gitweb/?p=occt.git), [cgal](https://github.com/CGAL/cgal), [eigen](https://eigen.tuxfamily.org/index.php?title=Main_Page) and [node](https://nodejs.org).

## Supported tags

The latest tags:

- 26.04-occt-7.8.1-cgal-6.0.2-eigen-3.4.0-node-26 (26.04-node-26)
- 24.04-occt-7.8.1-cgal-6.0.2-eigen-3.4.0-node-26 (24.04-node-26)
- 26.04-occt-7.8.1-cgal-6.0.2-eigen-3.4.0-node-24 (26.04-node-24)
- 24.04-occt-7.8.1-cgal-6.0.2-eigen-3.4.0-node-24 (24.04-node-24)

## Usage

Libraries are installed in `/opt/conda` (headers in `/opt/conda/include`, shared
libraries in `/opt/conda/lib`). The shared libraries are registered with the
dynamic linker, so no `LD_LIBRARY_PATH` or rpath is needed at runtime, e.g. for
node addons. When building, point the compiler and linker at them, e.g. in `binding.gyp`:

```json
"include_dirs": ["/opt/conda/include/opencascade"],
"libraries": ["-L/opt/conda/lib", "-lTKernel", "-lTKMath"]
```

## License

This container image contains `opencascade` which is under the GNU Lesser General
Public License (LGPL) version 2.1 with additional exception. See the licensing
information [here](https://www.opencascade.com/content/licensing).

This container image contains `CGAL` which is under the GNU Lesser General
Public License (LGPL) version 3+ and GLP version 3+. See the licensing
information [here](https://www.cgal.org/license.html)

This container image contains `Eigen` which is under the MPL2 license. See the licensing
information [here](https://www.mozilla.org/en-US/MPL/2.0/FAQ/)

Like other container images, this image contains some other software also that may
be under different licenses.

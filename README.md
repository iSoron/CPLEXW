CPLEXW.jl
=========
This package contains an unofficial low-level Julia wrapper for IBM® ILOG® CPLEX® Optimization Studio, automatically generated from the official C headers using [Clang.jl][1]. Unlike [CPLEX.jl][2], this wrapper allows access to all advanced CPLEX routines. However, it does not currently implement [MathOptInterface][3] or [MathProgBase][4] and therefore does not completely replace CPLEX.jl.

**Disclaimer:** You cannot use CPLEXW.jl without having purchased and installed a copy of CPLEX Optimization Studio from IBM. This wrapper is maintained by the JuliaOpt community, and is **not** officially developed or supported by IBM.


Installation
------------
Please follow the same install instructions from [CPLEX.jl][2], but instead of running `Pkg.add("CPLEX")`, run the following command instead:

    Pkg.add("https://github.com/iSoron/CPLEXW.git")

Usage
-----

The following example shows how can the package be used in standalone mode. After including `CPLEXW`, all standard CPLEX constants and functions (C API) become available to Julia. For a complete description of the available functions, please refer to the official CPLEX documentation. Julia's manual page on [how to call C functions][5] may also be helpful.

    using CPLEXW

    # Create CPLEX environment
    rval = [Cint(0)]
    env = CPXopenCPLEX(rval)

    # Change some parameters
    CPXsetintparam(env, CPX_PARAM_SCRIND, CPX_ON) # Print to the screen
    CPXsetdblparam(env, CPX_PARAM_TILIM, 30)      # Time limit in seconds

    # Create, populate and solve a problem
    lp = CPXcreateprob(env, rval, "problem")
    CPXreadcopyprob(env, lp, "myinstance.mps.gz", "mps")
    CPXmipopt(env, lp)

Usage with JuMP and CPLEX.jl
----------------------------
This package can also be used when you already have a JuMP optimization model (solved with CPLEX), but you need access to some advanced routines which are not available through CPLEX.jl. The next example illustrates this scenario:

    using JuMP, CPLEX, CPLEXW

    # Create JuMP + CPLEX.jl model
    model = direct_model(CPLEX.Optimizer())
    @variable(model, x >= 0)
    @objective(model, Min, x)
    optimize!(model)

    # Call low-level CPLEX function
    cpx = backend(model).inner
    CPXgetnumnz(cpx.env, cpx.lp)

Regenerating wrappers
---------------------
To regenerate the wrappers, run the script `gen/generate.jl`. The environment variable `CPLEX_INCLUDE_DIR` must be defined, and must point to the directory containing the header files. For example, if CPLEX is installed at `/opt/cplex-12.8`, the variable should be set to `/opt/cplex-12.8/cplex/include/ilcplex/`. If successful, the script will generate several files in the directory `gen/output`. Only the files `commons.jl` and `cplex.jl` are currently used.

[1]: https://github.com/JuliaInterop/Clang.jl
[2]: https://github.com/JuliaOpt/CPLEX.jl
[3]: https://github.com/JuliaOpt/MathOptInterface.jl
[4]: https://github.com/JuliaOpt/MathProgBase.jl
[5]: https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/
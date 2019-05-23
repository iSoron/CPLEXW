module CPLEXW
    using CEnum, Libdl

    if isfile(joinpath(dirname(@__FILE__),"..","deps","deps.jl"))
        include("../deps/deps.jl")
    else
        error("CPLEXW not properly installed. Please run Pkg.build(\"CPLEXW\")")
    end

    include("commons.jl")
    include("cplex.jl")

    foreach(names(@__MODULE__, all=true)) do s
       if startswith(string(s), "CPX")
           @eval export $s
       end
    end
end

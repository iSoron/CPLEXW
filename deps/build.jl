using Libdl

depsfile = joinpath(dirname(@__FILE__),"deps.jl")
if isfile(depsfile)
    rm(depsfile)
end

function write_depsfile(path)
    open(depsfile,"w") do f
        print(f,"const libcplex = ")
        show(f, path) # print with backslashes excaped on windows
        println(f)
    end
end

base_env = "CPLEX_STUDIO_BINARIES"
const cpxvers = ["128", "1280", "129", "1290"]

libnames = String["cplex"]
for v in reverse(cpxvers)
    if Sys.isapple()
        push!(libnames, "libcplex$v.dylib")
    elseif Sys.isunix()
        push!(libnames, "libcplex$v.so")
        if haskey(ENV, base_env)
            push!(libnames, joinpath(ENV[base_env], "libcplex$v.so"))
        end
    end
end

const wincpxvers = ["128", "1280", "129", "1290"]
@static if Sys.iswindows()
    for v in reverse(wincpxvers)
        env = base_env * v
        if haskey(ENV,env)
            for d in split(ENV[env],';')
                occursin("cplex", d) || continue
                if length(v) == 3
                    push!(libnames,joinpath(d,"cplex$(v)0"))
                else
                    push!(libnames,joinpath(d,"cplex$(v)"))
                end
            end
        end
    end
end

found = false

for l in libnames
    d = Libdl.dlopen_e(l)
    if d != C_NULL
        global found = true
        write_depsfile(Libdl.dlpath(d))
        break
    end
end

if !found
    error("Unable to locate CPLEX installation")
end

using Clang

if "CPLEX_INCLUDE_DIR" ∉ keys(ENV)
    error("CPLEX_INCLUDE_DIR must be defined")
end

CPLEX_INCLUDE_DIR = ENV["CPLEX_INCLUDE_DIR"]

mkpath("output")
context = Clang.init(
    headers=["$CPLEX_INCLUDE_DIR/cpxconst.h", "$CPLEX_INCLUDE_DIR/cplex.h"],
    common_file="commons.jl",
    output_dir="output",
    clang_includes=vcat(CPLEX_INCLUDE_DIR, LLVM_INCLUDE),
    clang_args = ["-I", CPLEX_INCLUDE_DIR],
    clang_diagnostics=true,
    header_wrapped=(header, cursorname) -> header == cursorname,
    header_library=header_name -> "libcplex"
)
Clang.run(context)

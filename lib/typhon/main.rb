module Typhon

  # Command line interface to Typhon.
  #
  # It should support the same command line options than the `python'
  # program. And additional options specific to Typhon and Rubinius.
  #
  # But currently we only take a python source name to compile and
  # run.
  #
  class Main

    def initialize
      @print = Compiler::Print.new
      @compile_only = false
      @evals = []
      @rest = []
    end

    def main(argv=ARGV)
      options(argv)
      evals unless @evals.empty?
      script unless @compile_only || @rest.empty?
      repl if !@compile_only && @rest.empty?
      compile if @compile_only
    end

    # Batch compile all python files given as arguments.
    def compile
      @rest.each do |py|
        begin
          Compiler.compile_file py, nil, @print
        rescue Compiler::Error => e
          e.show
        end
      end
    end

    # Evaluate code given on command line
    def evals
      raise "Eval not implemented yet."
    end

    # Run the given script if any
    def script
      CodeLoader.execute_file @rest.first, nil, @print
    end

    # Run the Typhon REPL unless we were given an script
    def repl
      raise "REPL not implemented yet"
    end

    # Parse command line options
    def options(argv)
      options = Rubinius::Options.new "Usage: typhon [options] [program]", 20
      options.doc "Typhon is a Python implementation for the Rubinius VM."
      options.doc "It is inteded to expose the same command line options as"
      options.doc "the `python` program and some Rubinius specific options."
      options.doc ""
      options.doc "OPTIONS:"

      options.on "-", "Read and evalute code from STDIN" do
        @evals << STDIN.read
      end

      options.on "--print-ast", "Print the Python AST" do
        @print.ast = true
      end

      options.on "--print-asm", "Print the Rubinius ASM" do
        @print.asm = true
      end

      options.on "--print-sexp", "Print the Python Sexp" do
        @print.sexp = true
      end

      options.on "--print-all", "Print Sexp, AST and Rubinius ASM" do
        @print.ast = @print.asm = @print.sexp = true
      end

      options.on "-C", "Just batch compile dont execute." do
        @compile_only = true
      end

      options.on "-e", "CODE", "Execute CODE" do |e|
        @evals << e
      end

      options.on "-h", "--help", "Display this help" do
        puts options
        exit 0
      end

      options.doc ""

      @rest = options.parse(argv)
    end

  end
end

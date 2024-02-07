<TeXmacs|2.1.4>

<style|generic>

<\body>
  <doc-data|<doc-title|Compiler Driver in VeGen>>

  <section|Pass Plugin>

  VeGen is implemented as an LLVM pass plug-in, which can be executed using
  both llvm-opt and clang.

  <cpp|clang -Os xxx.c -fpass-plugin=vegen.so -Xclang -load -Xclang vegen.so>

  <cpp|opt -load vegen.so -load-pass-plugin vegen.so -passes=slp -o /dev/null
  xxx.ll>

  <section|Intrinsic Wrapper>

  Inserting backend-specific instructions into a function via copying them
  directly from a compiled LLVM IR module represents a more straightforward
  approach compared to other methods.

  In particular, VeGen determines whether to insert an instruction according
  to the semantics of intrinsic functions. Consequently, VeGen first compiles
  these intrinsics before copying them over to the vectorizing function.

  <section|Header Files>

  The compiler driver of VeGen is called GSLP. GSLP directly includes the
  following header files:

  <\itemize>
    <item>Control Dependence

    <item>Block Builder

    <item>IR Vec

    <item>Inst Sema

    <item>Packer

    <item>Solver

    <item>Unroll Factor

    <item>Vector Pack Set

    <item>Scalarizer
  </itemize>

  <section|Command Line Options>

  - Wrappers Dir: specify the directory of the wrapper functions

  - Vectorize Only: only perform vectorization without packing

  - Filter: select the loops to be vectorized

  - Disable Unrolling: disable loop unrolling

  - Disable Cleanup: disable cleanup passes after GSLP

  - Disable Reduction Balancing: disable balancing the reduction tree

  <section|GSLP>

  GSLP is a function pass. It contains a reference to the bitcode of
  intrinsic wrapper functions and a LLVM target triple storing the
  architecture type.

  GSLP depends on many LLVM analyses, such as Scalar Evolution, Lazy Value
  Info, Alias Analysis, Dependence Analysis, Dominator Tree, Loop Info, Post
  Dominator Tree, Target Transform Info, and Block Frequency Info.

  <subsection|Registration>

  GSLP runs after the following passes: Scalarization, GVN Hoist, Unify
  Function Exit Nodes, Loop Simplify, Loop Rotate, and LCSSA.

  If cleanup passes are not disabled, the following passes will run after
  GSLP: CFG Simplification, Jump Threading, Instruction Combining, GVN, and
  Aggressive DCE.

  <subsection|Initialization>

  When initializing, GSLP gets the architecture type from an input module,
  then parses the IR file of wrapper functions accordingly.

  <subsection|Run on Function>

  <subsubsection|Skip Unsupported Functions>

  For now, let me ignore the balancing of the reduction tree.

  The first thing GSLP does when it runs on a function is to check whether it
  contains irreducible control flow. If it does, GSLP skips that function.
  Moreover, every basic block must terminate with a return instruction or a
  branch instruction, which excludes things like switches and invokes. GSLP
  also skips infinite loops.

  <subsubsection|Fill up Supported Intrinsics>

  <subsubsection|Loop Unrolling>

  <subsubsection|BottomUp Packing>

  <subsubsection|Code Generation>

  \;
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
    <associate|preamble|false>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-10|<tuple|5.3.2|1>>
    <associate|auto-11|<tuple|5.3.3|1>>
    <associate|auto-12|<tuple|5.3.4|1>>
    <associate|auto-13|<tuple|5.3.5|1>>
    <associate|auto-14|<tuple|5.3.5|2>>
    <associate|auto-15|<tuple|5.3.5|2>>
    <associate|auto-16|<tuple|5.3.5|2>>
    <associate|auto-17|<tuple|5.3.5|2>>
    <associate|auto-18|<tuple|5.3.5|2>>
    <associate|auto-19|<tuple|5.3.5|2>>
    <associate|auto-2|<tuple|2|1>>
    <associate|auto-20|<tuple|5.3.5|2>>
    <associate|auto-21|<tuple|5.3.5|2>>
    <associate|auto-22|<tuple|5.3.5|?>>
    <associate|auto-3|<tuple|3|1>>
    <associate|auto-4|<tuple|4|1>>
    <associate|auto-5|<tuple|5|1>>
    <associate|auto-6|<tuple|5.1|1>>
    <associate|auto-7|<tuple|5.2|1>>
    <associate|auto-8|<tuple|5.3|1>>
    <associate|auto-9|<tuple|5.3.1|1>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Pass
      Plugin> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Header
      Files> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <with|par-left|<quote|1tab>|2.1<space|2spc>Control Dependence
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|1tab>|2.2<space|2spc>Block Builder
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <with|par-left|<quote|1tab>|2.3<space|2spc>IR Vec
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <with|par-left|<quote|1tab>|2.4<space|2spc>Inst Sema
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>

      <with|par-left|<quote|1tab>|2.5<space|2spc>Packer
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-7>>

      <with|par-left|<quote|1tab>|2.6<space|2spc>Solver
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-8>>

      <with|par-left|<quote|1tab>|2.7<space|2spc>Unroll Factor
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-9>>

      <with|par-left|<quote|1tab>|2.8<space|2spc>Vector Pack Set
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-10>>

      <with|par-left|<quote|1tab>|2.9<space|2spc>Scalarizer
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-11>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|3<space|2spc>Command
      Line Options> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-12><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|4<space|2spc>GSLP>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-13><vspace|0.5fn>

      <with|par-left|<quote|1tab>|4.1<space|2spc>Registration
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-14>>

      <with|par-left|<quote|1tab>|4.2<space|2spc>Initialization
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-15>>

      <with|par-left|<quote|1tab>|4.3<space|2spc>Run on Function
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-16>>

      <with|par-left|<quote|2tab>|4.3.1<space|2spc>Skip Unsupported Functions
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-17>>

      <with|par-left|<quote|2tab>|4.3.2<space|2spc>Fill up Supported
      Intrinsics <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-18>>

      <with|par-left|<quote|2tab>|4.3.3<space|2spc>Loop Unrolling
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-19>>

      <with|par-left|<quote|2tab>|4.3.4<space|2spc>BottomUp Packing
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-20>>

      <with|par-left|<quote|2tab>|4.3.5<space|2spc>Code Generation
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-21>>
    </associate>
  </collection>
</auxiliary>
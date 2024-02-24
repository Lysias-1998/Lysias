<TeXmacs|2.1.4>

<style|generic>

<\body>
  \;

  <doc-data|<doc-title|Code Generation in VeGen>>

  The codegen does not generate new code, but rewrites the existing code.
  Specifically, it creates new basic blocks, inserts the vectorized code,
  adds the new blocks to the LLVM IR module, and then deletes the old blocks
  from the LLVM IR module.

  <section|VectorPackSet::codegen>

  VectorPackSet has a method called codegen. The method takes two parameters:
  a Builder and Paker (Pkr).

  The codegen does not generate new code, but rewrites the existing code.
  Specifically, it creates new basic blocks, inserts the vectorized code,
  adds the new blocks to the LLVM IR module, and then deletes the old blocks
  from the LLVM IR module.

  <\itemize-dot>
    <item>For each VP in AllPacks, and for each pair of instructions in VP,
    fuse or co-iterate their loops.

    <item>Create a ControlReifier with the context and the data analysis from
    Paker. Get the loop info and the vector loop info from Packer.

    <item>Define a function ReifyOneHots that takes a vector loop VL as a
    parameter. For each instruction I in VL, if I is a phi node and has a
    one-hot phi, reify its condition. A VLoop is an information add-on data
    structure that adds information to the LLVM Loop. It holds the dependency
    analysis results of all the instructions in the loop.

    <item>For each loop L in LI in preorder, get the VLoop of L, reify the
    back edge condition of VL, and call ReifyOneHots on VL. Then Call
    ReifyOneHots on the top vector loop.

    <item>For each VP in AllPacks, reify divergent loads and stores
    conditions.
  </itemize-dot>

  <subsection|Co-iteration>

  {coiteration immediately change the code or just mark it?}

  <subsection|Reifier>

  To perform control dependency analysis, VeGen crafts its own infrastructure
  instead of using the one in LLVM. It defines dedicated data structures to
  represent control flow as a chain of branch conditions, which aids control
  dependence analysis. Through this chain of block conditions, VeGen can
  generate a graph of basic blocks to reflect this condition representation,
  and generate actual boolean expressions and branch instructions according
  to the representation. This component is called Reifier. Reifier also
  caches the generated results, which are LLVM IR reflecting the
  representation, one cache per VLoop.

  <section|VectorCodeGen>

  VeGen defines a class VectorCodeGen with a method run, which takes no
  parameters and returns nothing.

  <subsection|emit loop>

  The emitLoop function lowers a VLoop to a pair of BasicBlocks: the Header
  and the Exit blocks. It takes a VLoop and a pre-header BasicBlock as
  parameters. The pre-header BasicBlock is the insertion point for the loop.
  The emitLoop function also creates three blocks and one instruction: a
  Header, a Latch, and an Exit block, and a Branch instruction. The Latch
  block connects to the Exit and Header blocks. The Header block is the entry
  block for the top-level loop in VeGen.

  The following steps are performed to generate the code for the loop:

  <\itemize-arrow>
    <item>Schedule the instructions and loops according to data dependence.

    <item>Pick out the <em|reduction packs>, which will be emitted last.

    <item>Generate code according to the schedule.

    <item>Emit reductions.

    <item>Patch the mu nodes using setIncomingValue and fixScalarUses, which
    patches scalar mu nodes.

    <item>Record guarded live outs.

    <item>Return the Header and the Exit.
  </itemize-arrow>
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
    <associate|auto-2|<tuple|1.1|1>>
    <associate|auto-3|<tuple|1.2|1>>
    <associate|auto-4|<tuple|2|1>>
    <associate|auto-5|<tuple|2.1|2>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>VectorPackSet::codegen>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <with|par-left|<quote|1tab>|1.1<space|2spc>Co-iteration
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2>>

      <with|par-left|<quote|1tab>|1.2<space|2spc>Reifier
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>VectorCodeGen>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4><vspace|0.5fn>

      <with|par-left|<quote|1tab>|2.1<space|2spc>emit loop
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>
    </associate>
  </collection>
</auxiliary>
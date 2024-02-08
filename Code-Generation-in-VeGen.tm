<TeXmacs|2.1.4>

<style|generic>

<\body>
  \;

  <doc-data|<doc-title|Code Generation in VeGen>>

  <section|Vector Pack Set>

  VectorPackSet has a method called codegen. The method takes two parameters:
  a Builder and Paker (Pkr).

  <\itemize-dot>
    <item>If AllPacks is not empty, print \PVectorized\Q and the name of the
    function from Pkr.

    <item>For each VP in AllPacks, and for each pair of instructions in VP,
    fuse or co-iterate their loops.

    <item>Create a ControlReifier with the context and the data analysis from
    Paker. Get the loop info and the vector loop info from Packer.

    <item>Define a function ReifyOneHots that takes a vector loop VL as a
    parameter. For each instruction I in VL, if I is a phi node and has a
    one-hot phi, reify its condition.

    <item>For each loop L in LI in preorder, get the vector loop for L, reify
    the back edge condition of VL, and call ReifyOneHots on VL. Then Call
    ReifyOneHots on the top vector loop.

    <item>For each VP in AllPacks, reify divergent loads and stores
    conditions.
  </itemize-dot>

  <section|Vector Code Gen>

  VeGen defines a class VectorCodeGen with a method run, which takes no
  parameters and returns nothing.

  <subsection|emit loop>

  The function emitLoop lowers a VLoop and returns the loop-header and exit
  blocks. It takes a VLoop and a BasicBlock as parameters, and returns a pair
  of BasicBlocks, which are the Header and the Exit blocks.\ 

  A VLoop is an information add-on data structure that adds information to
  the LLVM Loop. It holds the dependency analysis results of all the
  instructions in the loop.

  At the beginning, emitLoop creates three blocks and one instruction: a
  Header, a Latch, and an Exit block, and a Branch instruction. The Latch
  block will be wired with the Exit and Header blocks later.

  In VeGen, the top-level loop has the Header block as the entry block.

  The following steps are performed to generate the code for the loop:

  <\itemize-minus>
    <item>Schedule the instructions and loops according to data dependence.

    <item>Pick out the reduction packs, which will be emitted last.

    <item>Generate code according to the schedule.

    <item>Emit reductions.
  </itemize-minus>

  The function fixScalarUses patches scalar mu nodes.
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-2|<tuple|2|1>>
    <associate|auto-3|<tuple|2.1|1>>
    <associate|auto-4|<tuple|3|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Vector
      Pack Set> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Lower
      everything> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <with|par-left|<quote|1tab>|2.1<space|2spc>emit loop
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>
    </associate>
  </collection>
</auxiliary>
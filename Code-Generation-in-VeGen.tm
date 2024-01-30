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

  <section|Lower everything>

  VeGen defines a class VectorCodeGen with a method run, which takes no
  parameters and returns nothing.

  <subsection|emit loop>

  \;
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1|../../../../../home/ysz/.TeXmacs/texts/scratch/no_name_5.tm>>
    <associate|auto-2|<tuple|2|?|../../../../../home/ysz/.TeXmacs/texts/scratch/no_name_5.tm>>
    <associate|auto-3|<tuple|2.1|?|../../../../../home/ysz/.TeXmacs/texts/scratch/no_name_5.tm>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>
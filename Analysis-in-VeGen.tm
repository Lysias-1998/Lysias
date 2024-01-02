<TeXmacs|2.1.1>

<style|generic>

<\body>
  <doc-data|<doc-title|Analysis in VeGen>>

  <section|Consecutive Check>

  Whether load or store instructions touch consecutive addresses is important
  for vector memory instruction generation. Determining whether two
  instructions touch consecutive memory should be easy for hardware, but not
  for software. This is because the address may not be computable, and is
  often not computable at compile time. Additionally, load and store
  instructions may be in different basic blocks. Therefore, a non-trivial
  analysis is needed.

  <subsection|findConsecutiveAccesses>

  <subsection|isConsecutive>

  <subsection|isEquivalent>

  <section|Control Dependence>

  Control dependence analysis is a key technique in VLoop, as it appears 24
  times in the VLoop. It has various applications, such as computing the
  incoming conditions for phi nodes, assigning conditions to instructions
  within a block, finding the condition for taking the backedge versus
  exiting the loop, determining the feasibility of loop fusion, and
  performing coiteration (which seems to be a novel contribution of VeGen).

  <subsection|getConditionForBlock>

  <subsection|getConditionForEdge>

  <section|Global Dependence Analysis>

  Global dependence analysis is only used in the vector packer to determine
  whether a vector pack is valid and feasible.

  <subsection|getDepended>
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|auto-10|<tuple|2.5|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|auto-11|<tuple|3|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|auto-2|<tuple|1.1|1|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|auto-3|<tuple|1.2|1|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|auto-4|<tuple|1.3|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|auto-5|<tuple|2|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|auto-6|<tuple|2.1|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|auto-7|<tuple|2.2|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|auto-8|<tuple|3|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
    <associate|auto-9|<tuple|3.1|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_3.tm>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Consecutive
      Check> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Control
      Dependence> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|3<space|2spc>Data
      Dependence> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>
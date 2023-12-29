<TeXmacs|2.1.1>

<style|generic>

<\body>
  <doc-data|<doc-title|Vector Pack in VeGen>>

  <section|What's in a Vector Pack>

  A vector pack is not a collection of vectors, but rather a collection of
  instructions, each of which computes a scalar value.

  <section|Kinds of Vector Packs>

  <subsection|General>

  To create a general vector pack, we need a <code*|VectorPackContext>, an
  array of <code*|Matches>, two bit vectors of elements and their
  dependencies, an intrinsic that is the producer of this pack, and the LLVM
  <code*|TargetTransformInfo>.

  <subsection|Phi>

  To create a Phi pack, we do not need <code*|Matches> as we do for creating
  a general pack.

  <subsection|Load>

  To create a Load pack, we do not need <code*|Matches> since we already set
  it to be the load operation. Additionally, we need a condition pack to
  prevent unwanted reads from improper addresses and a flag to handle
  non-consecutive loads.

  <subsection|Store>

  Same as Load.

  <subsection|Reduction>

  <subsection|GEP>

  GEP stands for \Pget element pointer\Q.

  <subsection|Gamma>

  A Gamma pack is also called a Gated Phi Pack. It is a Phi node with
  incoming blocks replaced with explicit control conditions.

  <subsection|Cmp>

  <section|Construction of Vector Packs>

  To construct a vector pack, we need to perform three steps in common, in
  addition to filling the vector pack context.

  <subsection|computeOperandPacks>

  This step consists of two sub-steps: compute and canonicalize. In general,
  the compute step collects matched values into an array of values, primarily
  using a structure called <code*|OperandPack>. The canonicalize step wraps
  the <code*|OperandPack> with a C++ unique pointer and uses a map to ensure
  uniqueness.

  <subsubsection|computeOperandPacksForGeneral>

  <subsubsection|computeOperandPacksForLoad>

  <subsubsection|computeOperandPacksForStore>

  <subsubsection|computeOperandPacksForPhi>

  <subsection|computeOrderedValues>

  This step performs various tasks. For a general pack, it checks
  the<nbsp><code*|Matches><nbsp>and filters out the unmatched operands,
  setting them to<nbsp><code*|null>. For Load, Store, Phi, GEP, and Cmp, it
  simply copies values from the vector pack variants' own data structure
  to<nbsp><code*|OrderedValues>, creating a starting point for later
  processing.

  Reduction has only one value, and Gamma places only Phi nodes contained in
  it to the <code*|OrderedValues>.

  <subsection|computeCost>

  This step is self-contained. The cost is either read from an intrinsic
  guide or estimated using LLVM <code*|TargetTransformInfo> (primarily for
  load and store).
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-10|<tuple|2.8|1>>
    <associate|auto-11|<tuple|3|1>>
    <associate|auto-12|<tuple|3.1|1>>
    <associate|auto-13|<tuple|3.1.1|2>>
    <associate|auto-14|<tuple|3.1.2|2>>
    <associate|auto-15|<tuple|3.1.3|2>>
    <associate|auto-16|<tuple|3.1.4|2>>
    <associate|auto-17|<tuple|3.2|2>>
    <associate|auto-18|<tuple|3.3|2>>
    <associate|auto-2|<tuple|2|1>>
    <associate|auto-3|<tuple|2.1|1>>
    <associate|auto-4|<tuple|2.2|1>>
    <associate|auto-5|<tuple|2.3|1>>
    <associate|auto-6|<tuple|2.4|1>>
    <associate|auto-7|<tuple|2.5|1>>
    <associate|auto-8|<tuple|2.6|1>>
    <associate|auto-9|<tuple|2.7|1>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>What's
      in a Vector Pack> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Kinds
      of Vector Packs> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <with|par-left|<quote|1tab>|2.1<space|2spc>General
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|1tab>|2.2<space|2spc>Phi
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <with|par-left|<quote|1tab>|2.3<space|2spc>Load
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <with|par-left|<quote|1tab>|2.4<space|2spc>Store
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>

      <with|par-left|<quote|1tab>|2.5<space|2spc>Reduction
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-7>>

      <with|par-left|<quote|1tab>|2.6<space|2spc>GEP
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-8>>

      <with|par-left|<quote|1tab>|2.7<space|2spc>Gamma
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-9>>

      <with|par-left|<quote|1tab>|2.8<space|2spc>Cmp
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-10>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|3<space|2spc>Construction
      of Vector Packs> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-11><vspace|0.5fn>

      <with|par-left|<quote|1tab>|3.1<space|2spc>computeOperandPacks
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-12>>

      <with|par-left|<quote|2tab>|3.1.1<space|2spc>computeOperandPacksForGeneral
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-13>>

      <with|par-left|<quote|2tab>|3.1.2<space|2spc>computeOperandPacksForLoad
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-14>>

      <with|par-left|<quote|2tab>|3.1.3<space|2spc>computeOperandPacksForStore
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-15>>

      <with|par-left|<quote|2tab>|3.1.4<space|2spc>computeOperandPacksForPhi
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-16>>

      <with|par-left|<quote|1tab>|3.2<space|2spc>computeOrderedValues
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-17>>

      <with|par-left|<quote|1tab>|3.3<space|2spc>computeCost
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-18>>
    </associate>
  </collection>
</auxiliary>
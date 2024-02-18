<TeXmacs|2.1.4>

<style|generic>

<\body>
  <doc-data|<doc-title|VeGen: A Vectorizer Generator for SIMD and Beyond>>

  <section|Introduction>

  <section|Motivation>

  <section|Lane Level Parallelism>

  Lane LevelParallelism (LLP) is a relaxation of superword level parallelism
  (SLP), which models short-vector parallelism (in which an instruction
  executes multiple scalar operations in parallel) with the following
  restrictions:

  <\itemize>
    <item>The operations execute in lock-step.

    <item>The inputs and outputs of the operations reside in packed storage
    (usually implemented as vector registers). We refer to an element of such
    packed storage as a lane.
  </itemize>

  The properties of LLP depend on the semantics of individual instructions.
  Different instructions can use different combinations of operations or
  apply different cross-lae communication patterns.

  <subsection|Non-isomorphism>

  LLP allows different operations to execute in parallel, whereas SLP applies
  only one operation across all vector lanes.

  <subsection|Cross-lane communication>

  LLP allows an operation executing on one lane to access values from another
  input lane (as long as the lane is selected statically).

  <section|Workflow>

  <subsection|>

  <subsection|>

  <subsection|Pattern Matching>

  <\itemize>
    <item>The result of pattern matching is a match, an IR instruction DAG
    with possibly multiple live-ins and a single live-out. VeGen represents
    each match as a tuple consisting of its live-ins, live-out, and
    operation.

    <item>VeGen records the matched patterns in a match table,
    <math|<around*|\<langle\>|live<rsub|out><around*|(|m|)>,operation<around*|(|m|)>|\<rangle\>>\<rightarrow\>m>,
    for each match m.
  </itemize>

  <subsection|Vectorization>

  <\description>
    <item*|Vector Pack>A pack is a tuple <math|<around*|\<langle\>|v,<around*|[|m<rsub|1>,\<ldots\>,m<rsub|k>|]>|\<rangle\>>>,
    where <math|v> is a vector instruction with <math|k> output lanes, and
    <math|m<rsub|1>,\<ldots\>,m<rsub|k>> are a list of matches whose
    live-outs are independent.
  </description>

  <\itemize>
    <item>VeGen models vector loads and stores as two special kinds of packs,
    whose memory addresses must be contiguous.
  </itemize>

  <\description>
    <item*|Vector Operand>Vector Packs have vector operands, represented as a
    list of IR values. let <math|p=<around*|\<langle\>|v,<around*|[|m<rsub|1>,\<ldots\>,m<rsub|k>|]>|\<rangle\>>>
    be a vector pack, then <math|operand<rsub|i><around*|(|p|)>=<around*|[|x<rsub|1>,\<ldots\>,x<rsub|n>|]>>;
    where <math|x<rsub|j>\<in\><big|cup><rsub|k>live<rsub|in><around*|(|m<rsub|k>|)>>
    is one of the live-ins of the matches that should bind to the <math|j>'th
    lane of the <math|i>'th operand of the vector instruction <math|v>.

    <item*|Don't-Care Lanes>Some instructions don't use all of their input
    lanes. Each element of a vector operand (i.e.,
    <math|operand<rsub|i><around*|(|.|)>>) therefore takes the value of
    either a scalar IR value (from the input program) or don't-care.

    <item*|Producing a Vector Operand>A pack <math|p> produces a vector
    operand <math|x> if they have the same size (i.e.,
    <math|<around*|\||values<around*|(|p|)>|\|>=<around*|\||x|\|>>) and, for
    every lane <math|i>, <math|x<rsub|i>> is either
    <math|values<around*|(|p|)><rsub|i>> or don't-care. VeGen uses a separate
    routine to enumerate producer packs that are vector loads, which can be
    done efficiently because <em|only contiguous loads can be packed
    together>.

    <item*|Dependence and Legality>A pack <math|p<rsub|1>> depends on another
    pack <math|p<rsub|2>> if there exists an instruction
    <math|i\<in\>values<around*|(|p<rsub|1>|)>> that depends on another
    instruction <math|j\<in\>values<around*|(|p<rsub|2>|)>>. A set of packs
    are legal when there are no cycles in the dependence graph.

    <item*|Vector Pack Selection>Vectorization reduces to finding a subset of
    the matches and combining them into legal vector packs.
  </description>

  <subsection|Code Generation>

  Given a set of vector packs (and the input program), VeGen's code generator
  emits a vector program as a combination of:

  <\enumerate-numeric>
    <item>the scalar instructions not convered by the packs,

    <item>the compute vector instructions corresponding to the packs, and

    <item>the data-movement vector instructions that follow from the
    dependence among the packs and scalars.
  </enumerate-numeric>

  The code generation algorithm uses the target-specific functions
  <math|operand<rsub|i><around*|(|.|)>> generated from instruction semantics.

  <\description>
    <item*|Scheduling>

    <item*|Lowering>
  </description>

  <section|Vector Pack Selection>

  <\description>
    <item*|Optimization Objective and Cost Model>

    <item*|Pack Selection Heuristics>
  </description>

  <section|Implementation>
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-10|<tuple|4.4|2>>
    <associate|auto-11|<tuple|4.5|2>>
    <associate|auto-12|<tuple|5|2>>
    <associate|auto-13|<tuple|6|2>>
    <associate|auto-2|<tuple|2|1>>
    <associate|auto-3|<tuple|3|1>>
    <associate|auto-4|<tuple|3.1|1>>
    <associate|auto-5|<tuple|3.2|1>>
    <associate|auto-6|<tuple|4|1>>
    <associate|auto-7|<tuple|4.1|1>>
    <associate|auto-8|<tuple|4.2|1>>
    <associate|auto-9|<tuple|4.3|1>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Introduction>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Motivation>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|3<space|2spc>Lane
      Level Parallelism> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3><vspace|0.5fn>

      <with|par-left|<quote|1tab>|3.1<space|2spc>Non-isomorphism
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <with|par-left|<quote|1tab>|3.2<space|2spc>Cross-lane communication
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|4<space|2spc>Workflow>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6><vspace|0.5fn>

      <with|par-left|<quote|1tab>|4.1<space|2spc>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-7>>

      <with|par-left|<quote|1tab>|4.2<space|2spc>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-8>>

      <with|par-left|<quote|1tab>|4.3<space|2spc>Pattern Matching
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-9>>

      <with|par-left|<quote|1tab>|4.4<space|2spc>Vectorization
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-10>>

      <with|par-left|<quote|1tab>|4.5<space|2spc>Code Generation
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-11>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|5<space|2spc>Vector
      Pack Selection> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-12><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|6<space|2spc>Implementation>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-13><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>
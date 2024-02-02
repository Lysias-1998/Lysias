<TeXmacs|2.1.4>

<style|generic>

<\body>
  <doc-data|<doc-title|Superword Level Parallelism>>

  <\itemize-dot>
    <item>While different processors vary in the type and number of
    multimedia instructions offered, at the core of each is a set of short
    SIMD operations. These instructions operate concurrently on data that are
    packed in a single register or memory location.

    <item>Complicated loop transformation techniques such as loop fission and
    scalar expansion are required to parallelize loops that are only
    partially vectorizable. Consequently, no commercial compiler currently
    implements this functionality.

    <item>In the same way that loop unrolling translates loop level
    parallelism into ILP, vector parallelism can be transformed into SLP.
    This realizaiton allows for the parallelization of vectorizable loops
    using the same basic block analysis. As a result, our algorithm does not
    require any of the complicated loop transformations typically associated
    with vectorization.

    <item>The core of our algorithm begins by locating statements with
    adjacent memory references and packing them into groups of size two. From
    this initial seed, more groups are discovered based on the active set of
    packed data.

    <item>All groups are then merged into larger clusters of a size
    <em|consistent with the superword datapath width>.

    <item>Finally, a new schedule is produced for each basic block, where
    groups of packed statements are replaced with SIMD instructions.
  </itemize-dot>

  <section|Loop Unrolling>

  <\itemize-dot>
    <item>In order to ensure full utilization of the superword datapath in
    the presence of a vectorizable loop, the unroll factor must be customized
    to the data sizes used within the loop. For example, a vectorizable loop
    containing 16-bit values should be unrolled 8 times for a 128-bit
    datapath.

    <item>Our system currently unrolls loops based on the smallest data type
    present.
  </itemize-dot>

  <section|Alignment Analysis>

  <\itemize>
    <item>Alignment analysis determines the alignment of memory accesses with
    respect to a certain superword datapath width. For architectures that do
    not support unaligned memory accesses, alignment analysis can greatly
    improve the performance of our system.
  </itemize>

  <section|Pre-optimization>

  <\itemize>
    <item>This ensures that parallelism is not extracted from computation
    that would otherwise be eliminated.

    <item>Optimization include constant propagation, copy propagation, dead
    code elimination, common subexpression elimination, loop-invariant code
    motion, and redundant load/store elimination.
  </itemize>

  <section|Identifying Adjacent Memory References>

  <\itemize>
    <item>Statements containing adjacent memory references are the first
    candidates for packing. Adjacency is determined using both alignment
    information and array analysis.

    <item>When located, the first occurrence of each pair is added to the
    PackSet.

    <\description>
      <item*|Definition 1>A <em|Pack> is an n-tuple, where elements are
      independent <with|color|red|isomorphic> statements in a basic blocks.

      <item*|Definition 2>A <em|PackSet> is a set of <em|Packs>.

      <item*|Definition 3>A <em|Pair> is a <em|Pack> of size two, where the
      first statement is considered the left element, and the second
      statement is considered the right element.
    </description>

    <item>As an intermediate step, a statement us allowed to belong to two
    Pairs as long as it is the left element in one Pair and right in the
    other Pair. This allows the Combination phase to easily merge Pairs into
    larger Packs.
  </itemize>

  <section|Extending the PackSet>

  <\itemize>
    <item>New candidates can either:

    <\itemize>
      <item>Produce needed source operands in packed form, or

      <item>Use existing packed data as source operands.
    </itemize>

    <item>For two statements to be packable, they must meet the following
    criteria:

    <\itemize>
      <item>The statements are isomorphic.

      <item>The statements are independent.

      <item>The left statement is not already packed in a left position.

      <item>The right statement is not already packed in a right position.

      <item>Alignment information is consistent.

      <item>Execution time of the new parallel operation is estimated to be
      less than the sequential version.
    </itemize>
  </itemize>

  <section|Combination>

  <\itemize>
    <item>Two groups can be combined when the left statement of one is the
    same as the right statement of the other.
  </itemize>

  <section|Scheduling>

  <\itemize>
    <item>Dependence analysis before packing ensures that statements within a
    group can be executed safely in parallel. However, it may be the case
    that executing two groups produces a dependence violation.

    <item>The scheduling phase begins by scheduling statements based on their
    order in the original basic block.

    <item>If scheduling is ever inhibited by the presence of a cycle, the
    group containing the earliest unscheduled statement is split apart.
  </itemize>
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
    <associate|auto-2|<tuple|2|?>>
    <associate|auto-3|<tuple|3|?>>
    <associate|auto-4|<tuple|4|?>>
    <associate|auto-5|<tuple|5|?>>
    <associate|auto-6|<tuple|6|?>>
    <associate|auto-7|<tuple|7|?>>
    <associate|auto-8|<tuple|7|?>>
  </collection>
</references>
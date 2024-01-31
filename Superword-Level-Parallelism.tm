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

    <item>The core of our algorithm begins by locating statements with
    adjacent memory references and packing them into groups of size two. From
    this initial seed, more groups are discovered based on the active set of
    packed data. All groups are them merged into larger clusters of a size
    consistent with the superword datapath width. Finally, a new schedule is
    produced for each basic block, where groups of packed statements are
    replaced with SIMD instructions.
  </itemize-dot>
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
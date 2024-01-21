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

  This step has two sub-steps: compute and canonicalize. The compute sub-step
  gathers matched values into an array, mainly using a structure named
  OperandPack. This structure stores the vector type and the producers of the
  operand. The canonicalize sub-step wraps the OperandPack with a unique
  pointer and uses a map to guarantee uniqueness.

  <subsection|computeOrderedValues>

  For a general pack, it checks the <code*|Matches> and filters out the
  unmatched operands, setting them to <code*|null>. For Load, Store, Phi,
  GEP, and Cmp, it simply copies values from the vector pack variants' own
  data structure to <code*|OrderedValues>, creating a starting point for
  later processing. Reduction has only one value, and Gamma places only Phi
  nodes contained in it to the <code*|OrderedValues>.

  <subsection|computeCost>

  This step is self-contained. The cost is either read from an intrinsic
  guide or estimated using LLVM <code*|TargetTransformInfo> (primarily for
  load and store).

  <section|Vector Pack Context>

  A vector pack context is a data structure that maintains a bidirectional
  map between values and integers, enabling the use of a bitmap to record a
  set of values. It is an intra-function analysis.

  <section|Vector Pack Set>

  A vector pack set is an abstraction that manages a set of compatible vector
  packs and is responsible for lowering a set of packs to LLVM IR.

  <page-break>

  <section|Packer>

  <subsection|Packer Fields>

  The Packer class has many fields, most of which are pointers to other
  classes or data structures. Some of the fields of the Packer class are:

  <\itemize-arrow>
    <item>F: a pointer to the function.

    <item>VPCtx: an object of type VectorPackContext.

    <item>DA: an object of type GlobalDependenceAnalysis, which is a class
    that performs a global analysis of the memory dependencies between
    instructions in the function.

    <item>CDA: an object of type ControlDependenceAnalysis, which is a class
    that computes the control dependence graph of the function.

    <item>VLI: an object of type VLoopInfo, which is a class that represents
    a loop in the function and its vectorization properties.

    <item>TopVL: an object of type VLoop, which is a subclass of VLoopInfo
    that represents the top-level loop in the function.

    <item>MM: an object of type MatchManager, which is a class that manages
    the matching of expressions.

    <item>SecondaryMM: an optional object of type MatchManager, which is used
    to store a secondary match manager for the case when the primary match
    manager fails to find a suitable pattern. It is an optional object, which
    is a wrapper that may or may not contain a value of a given type.

    <item>BO: an object of type BlockOrdering, which is a class that defines
    an ordering of the basic blocks in the function.

    <item>SE: a pointer to an object of type ScalarEvolution, which is a
    class that provides information about the evolution of scalar values in
    loops, such as induction variables and trip counts.

    <item>DT: a pointer to an object of type DominatorTree, which is a class
    that represents the dominance tree of the function, which is a tree that
    shows the dominance relation between the basic blocks.

    <item>PDT: a pointer to an object of type PostDominatorTree, which is a
    class that represents the post-dominance tree of the function, which is a
    tree that shows the post-dominance relation between the basic blocks.

    <item>LI: a pointer to an object of type LoopInfo, which is a class that
    provides information about the loops in the function, such as their
    nesting structure and their headers and exits.

    <item>LoadDAG & StoreDAG: two objects of type ConsecutiveAccessDAG, which
    are classes that represent directed acyclic graphs (DAGs) of memory
    accesses that are consecutive in the same array or pointer. A DAG is a
    graph that has no cycles, meaning that there is no path from a node to
    itself.

    <item>Producers: a map object of type DenseMap, which is a class that
    implements a hash table that maps keys to values. The keys are pointers
    to objects of type OperandPack, which are classes that represent a pack
    of operands that are used by a vector pattern. The values are objects of
    type OperandProducerInfo, which are classes that store information about
    how the operands are produced.

    <item>BlockConditions: a map object of type DenseMap, which maps basic
    blocks to ControlCondition, which are classes that represent a condition
    that controls the execution of a block, such as a branch or a switch.

    <item>EdgeConditions: a map object of type DenseMap, which maps pairs of
    pointers to basic blocks to pointers to objects of type
    ControlConditions, which represent a condition that controls the
    transition from one block to another.

    <item>SupportedInsts: The elements are pointers to InstBinding.

    <item>LazyValueInfo: a pointer to an object of type LazyValueInfo, which
    is a class that provides information about the possible values of an
    instruction at a given point in the function, such as whether it is a
    constant or a range of values.

    <item>TTI: a pointer to an object of type TargetTransformInfo, which is a
    class that provides information about the target architecture, such as
    the instruction costs, the register pressure, and the vectorization
    capabilities.

    <item>BFI: a pointer to an object of type BlockFrequencyInfo, which is a
    class that provides information about the relative frequencies of the
    basic blocks in the function, based on a branch probability analysis.
  </itemize-arrow>

  <subsection|Packer Construction>

  The packer's constructor derives BlockConditions and EdgeConditions from
  ControlDependencyAnalysis (CDA), which uses LoopInfo, DominatorTree, and
  PostDominatorTree. BlockConditions and EdgeConditions act as a cache of
  CDA's methods: getConditionForBlock and getConditionForEdge. The latter
  method is required when the first instruction of a basic block is a PHI
  node. The constructor also collects all load and store instructions and
  assigns them to the Loads and Stores fields. Lastly, it defines a local
  helper variable, EquivalentAccesses, which is associated with the
  buildAccessDAG method and AccessLayoutInfo.

  <subsubsection|buildAccessDAG>

  AccessDAG, or ConsecutiveAccessDAG, is a type that maps an Instruction to a
  set of instructions. To construct this DAG, the following steps are
  performed: (1) group all access instructions by their type and the loop
  depth of their parent basic block; (2) for each group of access
  instructions, invoke the findConsecutiveAccesses method in ConsecutiveCheck
  to obtain a list of pairs of consecutive accesses; (3) add the consecutive
  accesses to the DAG.

  <subsubsection|AccessLayoutInfo>

  AccessLayoutInfo assigns linear numbers to load and store instructions that
  access the same memory object at different offsets. It is used to identify
  consecutive memory accesses and optimize them.

  <\itemize-minus>
    <item>The class has a nested struct called AddressInfo, which stores a
    pointer to an Instruction and an unsigned integer Id. The Instruction
    pointer is called Leader and it represents the first instruction in a
    group of consecutive accesses. The Id is the linear number assigned to
    the instruction, starting from 0 for the Leader.

    <item>The class has two private fields: Info and MemberCounts. Info is a
    DenseMap that maps an Instruction pointer to an AddressInfo struct.
    MemberCounts is a DenseMap that maps an Instruction pointer to an
    unsigned integer. Both maps use the Leader instruction as the key.

    <item>The class has two constructors: a default constructor and a
    constructor that takes a reference to a ConsecutiveAccessDAG object. A
    ConsecutiveAccessDAG is another class that represents a directed acyclic
    graph of consecutive memory accesses. The second constructor initialzes
    the Info and MemberCounts fields based on the information in the
    AccessDAG.

    <item>Two instructions are adjacent if they have the same Leader and
    their Ids differ by one.
  </itemize-minus>

  <subsection|Load & Store>

  Consecutive loads need to be packed into a load pack, and consecutive
  stores need to be packed into a store pack. VeGen defines AccessLayoutInfo
  to store the analysis results of consecutive memory accesses. It groups a
  bunch of consecutive accesses into a group, records their offsets from the
  lowest address access, and defines the lowest access instruction as the
  leader of the group.

  <subsection|Reverse Post Ordering>

  VeGen maintains the reverse post-order traversal of basic blocks within a
  function using a mapping from LLVM BasicBlock to an unsigned integer,
  denoted as BlockOrdering.

  <subsection|Methods>

  <subsubsection|checkIndependence>

  This function determines whether an instruction is independent of the
  elements in a bit vector that depends on another bit vector. It assumes
  that every instruction has a scalar id in the vector pack context and that
  a set of instructions can be represented by a bit vector. A bit vector can
  map an integer to a boolean value. Therefore, the dependency question is
  equivalent to some set operations. Given the id of an instruction, we check
  whether the id belongs to the elements or their dependencies, and whether
  the dependencies of the instruction (according to the Global Dependence
  Analysis results) intersect with the elements. If all these conditions are
  true, then the computation of the elements cannot affect the instruction.

  <subsubsection|isCompatible>

  <subsubsection|canSpeculateAt & findSpeculationCond>

  <subsubsection|matchSecondaryInsts>

  \;
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
    <associate|auto-12|<tuple|3.1|2>>
    <associate|auto-13|<tuple|3.2|2>>
    <associate|auto-14|<tuple|3.3|2>>
    <associate|auto-15|<tuple|4|2>>
    <associate|auto-16|<tuple|5|2>>
    <associate|auto-17|<tuple|6|3>>
    <associate|auto-18|<tuple|6.1|3>>
    <associate|auto-19|<tuple|6.2|4>>
    <associate|auto-2|<tuple|2|1>>
    <associate|auto-20|<tuple|6.2.1|4>>
    <associate|auto-21|<tuple|6.2.2|4>>
    <associate|auto-22|<tuple|6.3|4>>
    <associate|auto-23|<tuple|6.4|4>>
    <associate|auto-24|<tuple|6.5|4>>
    <associate|auto-25|<tuple|6.5.1|4>>
    <associate|auto-26|<tuple|6.5.2|4>>
    <associate|auto-27|<tuple|6.5.3|?>>
    <associate|auto-28|<tuple|6.5.4|?>>
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

      <with|par-left|<quote|1tab>|3.2<space|2spc>computeOrderedValues
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-13>>

      <with|par-left|<quote|1tab>|3.3<space|2spc>computeCost
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-14>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|4<space|2spc>Vector
      Pack Context> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-15><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|5<space|2spc>Vector
      Pack Set> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-16><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|6<space|2spc>Packer>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-17><vspace|0.5fn>

      <with|par-left|<quote|1tab>|6.1<space|2spc>Packer Fields
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-18>>

      <with|par-left|<quote|1tab>|6.2<space|2spc>Packer Construction
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-19>>

      <with|par-left|<quote|1tab>|6.3<space|2spc>Load & Store
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-20>>

      <with|par-left|<quote|1tab>|6.4<space|2spc>Reverse Post Ordering
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-21>>

      <with|par-left|<quote|1tab>|6.5<space|2spc>Methods
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-22>>

      <with|par-left|<quote|2tab>|6.5.1<space|2spc>checkIndependence
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-23>>

      <with|par-left|<quote|2tab>|6.5.2<space|2spc>isCompatible
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-24>>

      <with|par-left|<quote|2tab>|6.5.3<space|2spc>canSpeculateAt &
      findSpeculationCond <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-25>>

      <with|par-left|<quote|2tab>|6.5.4<space|2spc>matchSecondaryInsts
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-26>>
    </associate>
  </collection>
</auxiliary>
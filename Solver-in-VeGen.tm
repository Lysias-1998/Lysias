<TeXmacs|2.1.4>

<style|generic>

<\body>
  <doc-data|<doc-title|Solver in VeGen>>

  The role of the solver in the VeGen framework was initially unclear to me.
  I discovered that the optimizeBottomUp function, which is invoked in the
  GSLP driver, is the core of the solver. The solver aims to create a good
  VectorPackSet for later code generation, using planning and heuristics. The
  construction of a VectorPackSet is simple, but the codegen method is
  complex. The only interaction between the solver and the VectorPackSet is
  the tryAdd method, which checks the compatibility of the VectorPack to be
  added and updates the PackedValues, AllPacks, and ValueToPackMap.

  The main logic of the solver is implemented in another optimizeBottomUp
  function, which is overloaded with Packer and SeedOperands as parameters
  and returns a vector of VectorPacks to form a VectorPackSet. The solver is
  not a class, but a function named optimizeBottomUp in the solver file.

  <section|optimizeBottomUp>

  The function optimizeBottomUp is a solver that tries to find the best
  vectorization plan for a given set of seed operands. It takes four
  parameters:

  <\itemize-dot>
    <item>Packs: a reference to a vector of VectorPack pointers, which are
    data structures that represent a group of scalar instructions that can be
    packed into a single vector instruction. The function will append the
    optimal vector packs to this vector.

    <item>Pkr: a pointer to a Packer object, which is a class that handles
    the packing of vector instructions. It also provides access to the LLVM
    context and the target machine information.

    <item>SeedOperands: an array of OperandPack pointers, which are data
    structures that represent a group of scalar operands that can be packed
    into a single vector operand. These are the starting points for the
    vectorization process.

    <item>BlocksToIgnore: blocks that should be skipped.
  </itemize-dot>

  The function performs the following steps:

  <\itemize-minus>
    <item>It creates a CandidatePackSet object, which is a data structure
    that stores a set of candidate vector packs and a mapping from scalar
    instructions to vector packs that contain them.

    <item>It resizes the Inst2Packs vector, which is a member of the
    CandidatePackSet object, to match the number of values in the
    VectorPackContext. This vector stores a list of vector packs for each
    scalar instruction.

    <item>It iterates over the candidate vector packs and updates the
    Inst2Packs vector accordingly. For each vector pack, it gets the bitset
    of the elements that are packed, and for each set bit, it adds the vector
    pack to the corresponding list in the Inst2Packs vector.

    <item>It creates a Plan object, which represents a vectorization plan. It
    takes the packer as a parameter and initializes the plan with the scalar
    cost, which is the total cost of executing the scalar instructions
    without vectorization.

    <item>It calls the improvePlan function, which is defined in the same
    file as optimizeBottomUp, to find the optimal vectorization plan for the
    given seed operands and candidate vector packs. This function uses a
    greedy algorithm that tries to reduce the cost of the plan by adding or
    removing vector packs, while respecting the dependencies and constraints
    of the vectorization process.

    <item>It insert the vector packs from the optimal plan to the Packs
    vector, which is the output parameter of the function.

    <item>It calls the findDepCycle function, which is defined in the same
    file as optimizeBottomUp, to check if the vectorization plan introduces
    any dependence cycles that would prevent the correct execution of the
    program. If so, it prints an error message, clears the Packs vector, and
    returns the scalar cost as the result of the function.

    <item>Otherwise, it returns the cost of the optimal vectorization plan as
    the result of the function.
  </itemize-minus>
</body>

<\initial>
  <\collection>
    <associate|page-height|auto>
    <associate|page-medium|paper>
    <associate|page-type|letter>
    <associate|page-width|auto>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
  </collection>
</references>
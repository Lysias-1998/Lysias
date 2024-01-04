<TeXmacs|2.1.1>

<style|generic>

<\body>
  <doc-data|<doc-title|Block Builder in VeGen>>

  <section|Intrinsic Builder>

  The Create method of the Intrinsic Builder class shows how to copy a code
  snippet from one function to another basic block in LLVM.\ 

  First, we can obtain the function from a module using the getFunction
  method. Then, we can get a basic block from the obtained function (a
  function consists of one or more basic blocks). We also need to get the
  arguments from the function. All these tasks can be done through the
  function's iterator API.\ 

  Second, we create a value-to-value map to copy some IR instructions in the
  basic blocks. IR instructions with use-def relations can form a structure
  similar to a DAG. Copying a DAG requires a map, and so does copying
  instructions, since we have to let the new instruction refer to the new
  value. For function arguments, we first check whether the actual arguments
  (called operands) can be bitcast to the function formal parameters. If they
  can, we create a bitcast and map the function argument to the operand,
  since the new instructions generated by the copy need to refer to the
  operand, not the original argument.\ 

  Third, we examine all the instructions in the basic block until we meet a
  return instruction. We clone an instruction, insert the new instruction
  into the new block, and use the RemapInstruction LLVM function to replace
  the values according to the vmap, which means replacing all the operands of
  the newly created instruction with the new values. If the instruction is a
  call, which must be a call to another intrinsic in VeGen, we declare a new
  function in the new module and modify the call instruction to call it. This
  step is needed because functions will not be cloned like normal values and
  cannot be in the vmap. Finally, we get the new return value from the vmap
  using the old return value.

  <section|Block Builder>

  <subsection|Test>

  To test the block builder, a LLVM context is required. A LLVM context
  contains the type and constant uniquing tables, which are necessary for
  programmatically constructing an IR module.

  <subsection|Block and Condition>

  Blocks and conditions are closely related. A block is executed under a
  certain condition, and a condition can have a block (in a control flow
  graph) that is executed when the condition is met. We can freely decide
  which code is executed under which condition, as long as the condition is
  represented by a compiler-understandable predicate combined using the
  logical operators \Pand\Q and \Por\Q.

  <subsection|ConditionEmitter>

  The ConditionEmitter is responsible for emitting the actual LLVM IR
  expression that computes the condition. This expression is used in the
  BlockBuilder as the IR branch condition.

  <subsection|getBlockFor>

  This function takes a control condition as input and returns a basic block
  that belongs to a valid control flow graph (CFG) constructed based on the
  input condition. The function implements a recursive graph algorithm that
  traverses the control condition and recurs on the parent of the And
  condition and the CommonC of the Or condition. It uses two lookup tables,
  one for recording active conditions and the other for recording semi-active
  conditions.

  <subsubsection|Active Condition>

  <subsubsection|Semi-Active Condition>

  \;

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
    <associate|auto-2|<tuple|2|1>>
    <associate|auto-3|<tuple|2.1|1>>
    <associate|auto-4|<tuple|2.2|1>>
    <associate|auto-5|<tuple|2.3|1>>
    <associate|auto-6|<tuple|2.4|1>>
    <associate|auto-7|<tuple|2.4.1|?>>
    <associate|auto-8|<tuple|2.4.2|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Intrinsic
      Builder> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Block
      Builder> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <with|par-left|<quote|1tab>|2.1<space|2spc>Test
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|1tab>|2.2<space|2spc>Block and Condition
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <with|par-left|<quote|1tab>|2.3<space|2spc>ConditionEmitter
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <with|par-left|<quote|1tab>|2.4<space|2spc>getBlockFor
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>
    </associate>
  </collection>
</auxiliary>
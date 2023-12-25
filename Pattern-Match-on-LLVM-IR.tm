<TeXmacs|2.1.1>

<style|generic>

<\body>
  <doc-data|<doc-title|Pattern Match on LLVM IR>>

  <section|Mechanism>

  The pattern matching header in the LLVM project appears to be
  user-friendly. Consider the following code:

  <\cpp-code>
    \ \ llvm::PreservedAnalyses run(llvm::Function &F,

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ llvm::FunctionAnalysisManager
    &FAM) {

    \ \ \ \ using namespace llvm::PatternMatch;

    \ \ \ \ llvm::outs();

    \ \ \ \ for (auto &BB : F) {

    \ \ \ \ \ \ for (auto &I : BB) {

    \ \ \ \ \ \ \ \ llvm::Value *X, *Y;

    \ \ \ \ \ \ \ \ if (match(&I, m_Add(m_Value(X), m_Value(Y)))) {

    \ \ \ \ \ \ \ \ \ \ // I is an add instruction, and X and Y are its
    operands

    \ \ \ \ \ \ \ \ \ \ llvm::outs() \<less\>\<less\> "Found an add
    instruction: " \<less\>\<less\> I \<less\>\<less\> "\\n";

    \ \ \ \ \ \ \ \ \ \ llvm::outs() \<less\>\<less\> "Operand 1: "
    \<less\>\<less\> *X \<less\>\<less\> "\\n";

    \ \ \ \ \ \ \ \ \ \ llvm::outs() \<less\>\<less\> "Operand 2: "
    \<less\>\<less\> *Y \<less\>\<less\> "\\n";

    \ \ \ \ \ \ \ \ }

    \ \ \ \ \ \ }

    \ \ \ \ }

    \ \ \ \ return llvm::PreservedAnalyses::all();

    \ \ }
  </cpp-code>

  In this code, we need to understand the roles of the <cpp|match>,
  <cpp|m_Add>, and <cpp|m_Value> functions.

  <subsection|<cpp|match>>

  <cpp|match> has two variants, our code uses this one:

  <\cpp-code>
    template \<less\>typename Val, typename Pattern\<gtr\> bool match(Val *V,
    const Pattern &P) {

    \ \ return const_cast\<less\>Pattern &\<gtr\>(P).match(V);

    }
  </cpp-code>

  It just calls method <cpp|match> of a <cpp|Pattern> object.

  <subsection|<cpp|m_Add>>

  <\cpp-code>
    template \<less\>typename LHS, typename RHS\<gtr\>

    inline BinaryOp_match\<less\>LHS, RHS, Instruction::Add\<gtr\>
    m_Add(const LHS &L,

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ const
    RHS &R) {

    \ \ return BinaryOp_match\<less\>LHS, RHS, Instruction::Add\<gtr\>(L, R);

    }
  </cpp-code>

  <cpp|m_Add> relates symbol \PAdd\Q (in function name) to LLVM class
  <cpp|Instruction::Add>.

  <subsubsection|<cpp|BinaryOp_match>>

  <\cpp-code>
    template \<less\>typename LHS_t, typename RHS_t, unsigned Opcode,

    \ \ \ \ \ \ \ \ \ \ bool Commutable = false\<gtr\>

    struct BinaryOp_match {

    \ \ LHS_t L;

    \ \ RHS_t R;

    \;

    \ \ // The evaluation order is always stable, regardless of
    Commutability.

    \ \ // The LHS is always matched first.

    \ \ BinaryOp_match(const LHS_t &LHS, const RHS_t &RHS) : L(LHS), R(RHS)
    {}

    \;

    \ \ template \<less\>typename OpTy\<gtr\> inline bool match(unsigned Opc,
    OpTy *V) {

    \ \ \ \ if (V-\<gtr\>getValueID() == Value::InstructionVal + Opc) {

    \ \ \ \ \ \ auto *I = cast\<less\>BinaryOperator\<gtr\>(V);

    \ \ \ \ \ \ return (L.match(I-\<gtr\>getOperand(0)) &&
    R.match(I-\<gtr\>getOperand(1))) \|\|

    \ \ \ \ \ \ \ \ \ \ \ \ \ (Commutable && L.match(I-\<gtr\>getOperand(1))
    &&

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ R.match(I-\<gtr\>getOperand(0)));

    \ \ \ \ }

    \ \ \ \ return false;

    \ \ }

    \;

    \ \ template \<less\>typename OpTy\<gtr\> bool match(OpTy *V) { return
    match(Opcode, V); }

    };
  </cpp-code>

  This is what top level match function eventually calls.

  It is important to note that every LLVM Value has a unique enum number that
  can be used to determine its concrete class. This enum is defined in the
  header file <cpp|llvm/include/llvm/IR/Value.def>. By using this enum, the
  <cpp|BinaryOp_match> function can directly determine whether the input
  value is an add instruction.

  What are the types of L and R in the code? Based on their usage in the
  code, it can be inferred that they must be classes that also have a
  <cpp|match> method.

  <subsection|<cpp|m_Value>>

  <\cpp-code>
    inline bind_ty\<less\>Value\<gtr\> m_Value(Value *&V) { return V; }
  </cpp-code>

  Similar to <cpp|m_Add>, <cpp|m_Value> is a wrapper function that returns a
  structure with a match method.

  <subsubsection|<cpp|bind_ty>>

  <\cpp-code>
    template \<less\>typename Class\<gtr\> struct bind_ty {

    \ \ Class *&VR;

    \;

    \ \ bind_ty(Class *&V) : VR(V) {}

    \;

    \ \ template \<less\>typename ITy\<gtr\> bool match(ITy *V) {

    \ \ \ \ if (auto *CV = dyn_cast\<less\>Class\<gtr\>(V)) {

    \ \ \ \ \ \ VR = CV;

    \ \ \ \ \ \ return true;

    \ \ \ \ }

    \ \ \ \ return false;

    \ \ }

    };
  </cpp-code>

  It maintains a reference to a pointer after construction and populates that
  pointer when the given class is matched.
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-2|<tuple|1.1|1>>
    <associate|auto-3|<tuple|1.2|1>>
    <associate|auto-4|<tuple|1.2.1|1>>
    <associate|auto-5|<tuple|1.3|2>>
    <associate|auto-6|<tuple|1.3.1|2>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Mechanism>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <with|par-left|<quote|1tab>|1.1<space|2spc><with|mode|<quote|prog>|prog-language|<quote|cpp>|font-family|<quote|rm>|match>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2>>

      <with|par-left|<quote|1tab>|1.2<space|2spc><with|mode|<quote|prog>|prog-language|<quote|cpp>|font-family|<quote|rm>|m_Add>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|2tab>|1.2.1<space|2spc><with|mode|<quote|prog>|prog-language|<quote|cpp>|font-family|<quote|rm>|BinaryOp_match>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <with|par-left|<quote|1tab>|1.3<space|2spc><with|mode|<quote|prog>|prog-language|<quote|cpp>|font-family|<quote|rm>|m_Value>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <with|par-left|<quote|2tab>|1.3.1<space|2spc><with|mode|<quote|prog>|prog-language|<quote|cpp>|font-family|<quote|rm>|bind_ty>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>
    </associate>
  </collection>
</auxiliary>
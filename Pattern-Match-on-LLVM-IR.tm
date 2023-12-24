<TeXmacs|2.1.1>

<style|generic>

<\body>
  <doc-data|<doc-title|Pattern Match on LLVM IR>>

  <section|Mechanism>

  The pattern match header in LLVM project seems easy to use. Considaring the
  code:

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

  We need to figure out what <cpp|match>, <cpp|m_Add>, and <cpp|m_Value> do.

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

  Note that every LLVM Value has a unique enum number that can be used to
  determine its concrete class, which is defined in
  <cpp|llvm/include/llvm/IR/Value.def>. Through it, <cpp|BinaryOp_match> can
  directly tell whether the input value is a add instruction.

  What is the type of L and R in the code? According to their usage in the
  code, they must be some classes that have method <cpp|match> too.

  <subsection|<cpp|m_Value>>

  <\cpp-code>
    inline bind_ty\<less\>Value\<gtr\> m_Value(Value *&V) { return V; }
  </cpp-code>

  Like <cpp|m_Add>, <cpp|m_Value> is a wraper function that returns a
  structure which has a match method.

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

  It keeps a reference to a pointer after construction. Populates that
  pointer when given Class is matched.
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_2.tm>>
    <associate|auto-2|<tuple|1.1|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_2.tm>>
    <associate|auto-3|<tuple|1.2|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_2.tm>>
    <associate|auto-4|<tuple|1.2.1|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_2.tm>>
    <associate|auto-5|<tuple|1.3|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_2.tm>>
    <associate|auto-6|<tuple|1.3.1|?|..\\..\\..\\AppData\\Roaming\\TeXmacs\\texts\\scratch\\no_name_2.tm>>
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
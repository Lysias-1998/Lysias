<TeXmacs|2.1.1>

<style|generic>

<\body>
  <doc-data|<doc-title|Vector Operation Description in VeGen>>

  <section|Vector Operation>

  What would be a good abstraction for vector operations? To be honest, I
  cannot identify any linear algebra-related properties in those SIMD
  instructions. They are simply hardware implementations of frequently used
  operations in regular code.

  If we consider LLVM IR to be an abstraction over the scalar parts of
  various ISAs, then it follows that if we do not thoroughly consider certain
  types of new instructions like SIMD, they will only be utilized in highly
  specialized libraries. Consequently, they will not be incorporated into the
  IR or the compiler optimization process.

  <section|Abstraction in Vegen>

  In the paper <cite*|VeGen: A Vectorizer Generator for SIMD and Beyond>, an
  instruction is represented as a list of lanes, each of which is
  characterized by a BoundOperation. The author has kindly open-sourced the
  code for this paper, allowing us to examine its abstraction over vector
  instructions.

  For example, the <cpp|_mm256_addsub_pd> is like this:

  <\cpp>
    InstBinding(

    \ \ \ \ "_mm256_addsub_pd", {"avx"}, InstSignature{{256, 256}, {256},
    false},

    \ \ \ \ {BoundOperation(&Operation3, {InputSlice{0, 0, 64}, InputSlice{1,
    0, 64}}),

    \ \ \ \ \ BoundOperation(&Operation4,

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ {InputSlice{0, 64, 128},
    InputSlice{1, 64, 128}}),

    \ \ \ \ \ BoundOperation(&Operation3,

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ {InputSlice{0, 128, 192},
    InputSlice{1, 128, 192}}),

    \ \ \ \ \ BoundOperation(&Operation4,

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ {InputSlice{0, 192, 256},
    InputSlice{1, 192, 256}})},

    \ \ \ \ 1.0)
  </cpp>

  <subsection|InstSignature>

  <\cpp>
    struct InstSignature {

    \ \ std::vector\<unsigned\> InputBitwidths;

    \ \ std::vector\<unsigned\> OutputBitwidths;

    \ \ bool HasImm8;

    \ \ unsigned numInputs() const { return InputBitwidths.size(); }

    \ \ unsigned numOutputs() const { return OutputBitwidths.size(); }

    };
  </cpp>

  This structure records the number and bitwidths of the input and output
  parameters of a vector instruction.

  <cpp|InstSignature{{256, 256}, {256}, false}>

  The only unusual aspect is the mysterious <cpp|HasImm8> member. This is
  because some vector instructions receive an immediate operand (typically an
  8-bit integer) that cannot be passed as a variable (i.e., a register) but
  only as an immediate value. This distinction necessitates different code
  generation, hence the need to record this information.

  <subsection|InputSlice>

  <\cpp>
    struct InputSlice {

    \ \ unsigned InputId;

    \ \ unsigned Lo, Hi;

    \ \ unsigned size() const { return Hi - Lo; }

    \ \ bool operator\<less\>(const InputSlice &Other) const {

    \ \ \ \ return std::tie(InputId, Lo, Hi) \<less\>

    \ \ \ \ \ \ \ \ \ \ \ std::tie(Other.InputId, Other.Lo, Other.Hi);

    \ \ }

    };
  </cpp>

  The input slice structure further divides the input long vector operands.
  The <cpp|InputId> member indicates which operand this slice comes from. The
  <cpp|Lo> and <cpp|Hi> members describe the slice range.

  Overall, an input slice is a division of some inputs, in order to feed
  parts of the inputs to a operation.

  <subsection|Operation>

  <\cpp>
    // Interface that abstractly defines an operation

    struct Operation {

    \ \ virtual ~Operation() {}

    \ \ struct Match {

    \ \ \ \ bool Commutative; // applies when the operation is binary

    \ \ \ \ std::vector\<less\>llvm::Value *\<gtr\> Inputs;

    \ \ \ \ // FIXME: make this an Instruction instead

    \ \ \ \ llvm::Value *Output;

    \ \ \ \ bool operator\<less\>(const Match &Other) const {

    \ \ \ \ \ \ return std::tie(Output, Inputs) \<less\>
    std::tie(Other.Output, Other.Inputs);

    \ \ \ \ }

    \ \ \ \ bool operator==(const Match &Other) const {

    \ \ \ \ \ \ return Output == Other.Output && Inputs == Other.Inputs;

    \ \ \ \ }

    \ \ };

    \ \ // `match' returns true if `V` is matched.

    \ \ // If a match is found, additionally return the matched liveins

    \ \ virtual bool match(llvm::Value *V,
    llvm::SmallVectorImpl\<less\>Match\<gtr\> &Matches) const = 0;

    };
  </cpp>

  The <code*|Operation> class has a virtual and abstract <code*|match>
  method. This means that different operations will have different patterns
  to match. The concrete <code*|match> method is required to fill in a vector
  of <code*|match> objects, which capture the input and output values in the
  original code (the code to be vectorized).

  For example, Operation17's match method is shown below. If the value has a
  64-bit width and is a zero extension of another 32-bit value tmp0, then the
  noncommutative operation from tmp0 to value is pushed as a match to the
  match list.

  <\cpp>
    class : public Operation {

    \ \ bool match(Value *V, SmallVectorImpl\<Match\> &Matches) const
    override {

    \ \ \ \ Value *tmp0;

    \ \ \ \ bool Matched = hasBitWidth(V, 64) &&

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ PatternMatch::match(V,
    m_ZExt(m_Value(tmp0))) &&

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ hasBitWidth(tmp0, 32);

    \ \ \ \ if (Matched)

    \ \ \ \ \ \ Matches.push_back({false,

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ // matched live ins

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ {tmp0},

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ // the matched value
    itself

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ V});

    \ \ \ \ return Matched;

    \ \ }

    } Operation17;
  </cpp>

  <subsection|BoundOperation>

  <\cpp>
    // An operation explicitly bound to an instruction and its input(s)

    class BoundOperation {

    \ \ const Operation *Op;

    \ \ std::vector\<InputSlice\> BoundSlices;

    public:

    \ \ // A bound operation

    \ \ BoundOperation(const Operation *Op, std::vector\<InputSlice\>
    BoundSlices)

    \ \ \ \ \ \ : Op(Op), BoundSlices(BoundSlices) {}

    \ \ const Operation *getOperation() const { return Op; }

    \ \ llvm::ArrayRef\<InputSlice\> getBoundSlices() const { return
    BoundSlices; }

    };
  </cpp>

  Each BoundOperation produces one element in the output vector. Note that
  the InputSlice is simply a recorded relationship between the output
  vector's element and the input vector's elements. The matched Operation
  holds references to the Value object in an LLVM IR module.

  <subsection|InstBinding>

  Putting it all together,

  <\cpp>
    // An instruction is a list of lanes,

    // each of which characterized by a BoundOperation

    class InstBinding {

    \ \ InstSignature Sig;

    \ \ std::string Name;

    \ \ std::vector\<less\>std::string\<gtr\> TargetFeatures;

    \ \ std::vector\<less\>BoundOperation\<gtr\> LaneOps;

    \ \ llvm::Optional\<less\>float\<gtr\> Cost;

    \;

    public:

    \ \ InstBinding(std::string Name, std::vector\<less\>std::string\<gtr\>
    TargetFeatures,

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ InstSignature Sig,
    std::vector\<less\>BoundOperation\<gtr\> LaneOps,

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ llvm::Optional\<less\>float\<gtr\> Cost =
    llvm::None)

    \ \ \ \ \ \ : Sig(Sig), Name(Name), TargetFeatures(TargetFeatures),
    LaneOps(LaneOps),

    \ \ \ \ \ \ \ \ Cost(Cost) {}

    \ \ virtual ~InstBinding() {}

    \ \ virtual float getCost(llvm::TargetTransformInfo *,

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ llvm::LLVMContext &)
    const {

    \ \ \ \ assert(Cost.hasValue());

    \ \ \ \ return Cost.getValue();

    \ \ }

    \ \ llvm::ArrayRef\<less\>std::string\<gtr\> getTargetFeatures() const {

    \ \ \ \ return TargetFeatures;

    \ \ }

    \ \ const InstSignature &getSignature() const { return Sig; }

    \ \ llvm::ArrayRef\<less\>BoundOperation\<gtr\> getLaneOps() const {
    return LaneOps; }

    \ \ virtual llvm::Value *emit(llvm::ArrayRef\<less\>llvm::Value *\<gtr\>
    Operands,

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ IntrinsicBuilder
    &Builder) const {

    \ \ \ \ return Builder.Create(Name, Operands);

    \ \ }

    \ \ llvm::StringRef getName() const { return Name; }

    };
  </cpp>
</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
    <associate|preamble|false>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-2|<tuple|2|1>>
    <associate|auto-3|<tuple|2.1|1>>
    <associate|auto-4|<tuple|2.2|2>>
    <associate|auto-5|<tuple|2.3|2>>
    <associate|auto-6|<tuple|2.4|3>>
    <associate|auto-7|<tuple|2.5|3>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Vector
      Operation> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Abstraction
      in Vegen> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2><vspace|0.5fn>

      <with|par-left|<quote|1tab>|2.1<space|2spc>InstSignature
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|1tab>|2.2<space|2spc>InputSlice
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <with|par-left|<quote|1tab>|2.3<space|2spc>Operation
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <with|par-left|<quote|1tab>|2.4<space|2spc>BoundOperation
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>

      <with|par-left|<quote|1tab>|2.5<space|2spc>InstBinding
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-7>>
    </associate>
  </collection>
</auxiliary>
<TeXmacs|2.1.1>

<style|generic>

<\body>
  <doc-data|<doc-title|Scalar Evolution in LLVM>>

  <section|Example>

  <subsection|Source>

  <\cpp>
    void foo(float *a, uint64_t n, uint64_t k) {

    \ \ \ \ \ \ \ \ for (uint64_t i = 0; i \<less\> n; i++) {

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ a[i] = i * k;

    \ \ \ \ \ \ \ \ }

    }
  </cpp>

  <subsection|LLVM IR>

  <cpp|clang -Oz -S sourcefile.cpp -emit-llvm>

  <\cpp>
    ; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind
    optsize uwtable writeonly

    define dso_local void @_Z3fooPfmm(float* nocapture noundef writeonly %0,
    i64 noundef %1, i64 noundef %2) local_unnamed_addr #0 {

    \ \ br label %4

    \;

    4: \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ;
    preds = %8, %3

    \ \ %5 = phi i64 [ 0, %3 ], [ %12, %8 ]

    \ \ %6 = icmp eq i64 %5, %1

    \ \ br i1 %6, label %7, label %8

    \;

    7: \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ;
    preds = %4

    \ \ ret void

    \;

    8: \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ ;
    preds = %4

    \ \ %9 = mul i64 %5, %2

    \ \ %10 = uitofp i64 %9 to float

    \ \ %11 = getelementptr inbounds float, float* %0, i64 %5

    \ \ store float %10, float* %11, align 4, !tbaa !5

    \ \ %12 = add i64 %5, 1

    \ \ br label %4, !llvm.loop !9

    }
  </cpp>

  <subsection|Scalar Evolution>

  <cpp|opt --enable-new-pm=0 -analyze -scalar-evolution sourcefile.ll>

  <\cpp>
    Printing analysis 'Scalar Evolution Analysis' for function '_Z3fooPfmm':

    Classifying expressions for: @_Z3fooPfmm

    \ \ %5 = phi i64 [ 0, %3 ], [ %12, %8 ]

    \ \ --\<gtr\> \ {0,+,1}\<less\>%4\<gtr\> U: full-set S: full-set
    \ \ \ \ \ \ \ \ \ \ \ \ \ Exits: %1 \ \ \ \ \ \ \ \ \ \ \ \ \ \ LoopDispositions:
    { %4: Computable }

    \ \ %9 = mul i64 %5, %2

    \ \ --\<gtr\> \ {0,+,%2}\<less\>%4\<gtr\> U: full-set S: full-set
    \ \ \ \ \ \ \ \ \ \ \ \ Exits: (%1 * %2)
    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ LoopDispositions: { %4: Computable }

    \ \ %11 = getelementptr inbounds float, float* %0, i64 %5

    \ \ --\<gtr\> \ {%0,+,4}\<less\>%4\<gtr\> U: full-set S: full-set
    \ \ \ \ \ \ \ \ \ \ \ \ Exits: ((4 * %1) + %0)
    \ \ \ \ \ \ \ \ \ LoopDispositions: { %4: Computable }

    \ \ %12 = add i64 %5, 1

    \ \ --\<gtr\> \ {1,+,1}\<less\>nw\<gtr\>\<less\>%4\<gtr\> U: full-set S:
    full-set \ \ \ \ \ \ \ \ \ Exits: (1 + %1)
    \ \ \ \ \ \ \ \ LoopDispositions: { %4: Computable }

    Determining loop execution counts for: @_Z3fooPfmm

    Loop %4: backedge-taken count is %1

    Loop %4: max backedge-taken count is -1

    Loop %4: Predicated backedge-taken count is %1

    \ Predicates:

    \;

    Loop %4: Trip multiple is 1
  </cpp>

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
    <associate|auto-2|<tuple|1.1|1>>
    <associate|auto-3|<tuple|1.2|1>>
    <associate|auto-4|<tuple|1.3|1>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Example>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <with|par-left|<quote|1tab>|1.1<space|2spc>Source
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2>>

      <with|par-left|<quote|1tab>|1.2<space|2spc>LLVM IR
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|1tab>|1.3<space|2spc>Scalar Evolution
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>
    </associate>
  </collection>
</auxiliary>
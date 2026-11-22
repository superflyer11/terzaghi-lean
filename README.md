# terzaghi-lean

A machine-checked proof, in the Lean 4 theorem prover, that Terzaghi's
solution for one-dimensional consolidation satisfies its equation and
boundary conditions.

Started 22 November 2026 as a learning project.

## Why do this

### 1. To separate the mathematics from the assumptions

Terzaghi's theory has two parts: **assumptions about soil** (listed below),
which are engineering judgements and where real predictions go wrong, and
**mathematics**, which follows from those assumptions by pure reasoning and has
been settled since 1925.

In real engineering practice, the two parts are almost always mixed up, so it
is hard to see which step is a physical assumption and which is just algebra.
Lean draws the line exactly by checking everything that can be accepted.
Anything Lean cannot check must be written down as an explicit assumption. At
the end, the list of assumptions *is* the theory's engineering content, stated
in full.

### 2. A first step towards rigorous soil mechanics

Terzaghi's theory is the one-dimensional special case of Biot's
poroelasticity. Darcy's law and effective stress can themselves be derived
(from homogenisation and mixture theory), and Cam clay sits inside the
mathematical theory of plasticity. This project starts with the smallest piece
of that structure that can be fully checked. Terzaghi's equation is
mathematically the heat equation, and even that is only partly formalised in
Lean (see [References](#references)).

## What is proved and what is assumed

### The problem, in non-dimensional form

| Symbol | Meaning |
|---|---|
| `Z = z / H` | depth divided by the drainage path length H, so `0 ≤ Z ≤ 1` |
| `T = Tv = cv t / H²` | time factor |
| `u(Z, T)` | excess pore pressure |

Terzaghi's equation `∂u/∂t = cv ∂²u/∂z²` becomes `∂u/∂T = ∂²u/∂Z²`, so every
result holds for any soil and any layer thickness.

Boundary conditions, single drainage:

- top, `Z = 0`, drained: `u = 0`
- base, `Z = 1`, impermeable: `∂u/∂Z = 0` (no gradient, so no flow, by Darcy)

One term of the solution is `u = sin(M Z) · exp(−M² T)`, with `M = π(2m + 1)/2`.

### Terzaghi's physical assumptions (not checked by Lean)

1. The soil is fully saturated.
2. The soil grains and the pore water are incompressible.
3. Flow and strain are vertical only (one-dimensional).
4. Darcy's law holds.
5. Permeability k and the coefficient of volume compressibility mv stay
   constant, so cv = k / (mv γw) is constant.
6. Strains are small, so the layer thickness H does not change.
7. The load is applied instantly and stays constant, so Δσ′ = −Δu.
8. Secondary compression (creep) is ignored.

### Progress

| Step | Statement | Status | Where |
|---|---|---|---|
| 0 | Learn Lean basics (*Mathematics in Lean*) | — | — |
| 1a | One term satisfies `∂u/∂T = ∂²u/∂Z²` | proved | `consolidation_equation` |
| 1b | One term has zero slope at the impermeable base | proved | `base_impermeable` |
| 1c | One term is zero at the drained top | open: first exercise | `top_drained` |
| 2 | Any finite sum of terms satisfies the equation and both boundaries (superposition) | not started | — |
| 3 | The full infinite series converges and can be differentiated term by term | not started; the hard part | — |
| 4 | Uniqueness of the solution; average degree of consolidation U(Tv) | not started | — |
| — | Derive the equation from assumptions 1 to 8 | possible later step | — |

All proofs are in [TerzaghiLean/OneTerm.lean](TerzaghiLean/OneTerm.lean).

## Building

```bash
lake exe cache get   # download Mathlib's prebuilt files (about 5 GB)
lake build
```

## References

- Terzaghi, K. (1943). *Theoretical Soil Mechanics*. Wiley.
- Heat equation in Lean: [Lean formalisation of PDE topics](https://github.com/weiran-sun/pde);
  [Lean for PDEs 2025 workshop](https://leanprover-community.github.io/archive/stream/534314-Lean-for-PDEs-2025/topic/Projects.html)
- Avigad, J. and Massot, P. *Mathematics in Lean*. Free online textbook.

## AI use

Proofs are written with help from a LLM. The intended outcome is that a human should be able to digest this.

## Licence

[Apache License 2.0](LICENSE), the same licence as Lean and Mathlib.

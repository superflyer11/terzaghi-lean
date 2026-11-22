# terzaghi-lean

A machine-checked proof, in the Lean 4 theorem prover, that Terzaghi's
solution for one-dimensional consolidation satisfies its equation and
boundary conditions.

Started 22 November 2026 as a learning project.

## Why do this

### 1. To separate the mathematics from the assumptions

Terzaghi's consolidation theory has two quite different parts:

- **Assumptions about soil.** Saturated soil, one-dimensional flow, Darcy's
  law, a constant coefficient of consolidation cv, and so on (full list
  below). These are engineering judgements. They are where real predictions
  go wrong.
- **Mathematics.** Given those assumptions, the governing equation and its
  series solution follow by pure reasoning. This part has been settled since
  1925. It is never the reason a settlement prediction is wrong.

A textbook mixes the two, so it is hard to see which step is a physical
assumption and which is just algebra. Lean draws the line exactly. Lean checks
everything it accepts, and anything it cannot check must be written down as an
explicit assumption. At the end, the list of assumptions *is* the theory's
engineering content, stated in full.

This project does not make the theory more accurate for real clay. It makes
plain which parts can be trusted completely and which parts need engineering
judgement.

### 2. To understand every step

A textbook says "it can be shown that" and "differentiating term by term".
Lean accepts neither, and makes you prove each step. Writing the proof
yourself means you know why each condition, eigenvalue and series term is
there, not just that it is.

### 3. It does not seem to have been done

A Google search in November 2026 found no formalisation of Terzaghi's
consolidation theory in Lean or any other proof assistant. Terzaghi's equation
is mathematically the heat equation, with excess pore pressure in place of
temperature and cv in place of thermal diffusivity. Even the heat equation is
only partly formalised, in side projects and workshop exercises rather than in
Lean's main maths library, Mathlib (see [References](#references)).
Terzaghi's specific case, a finite layer drained at one boundary and sealed at
the other, solved as a Fourier sine series, was not found anywhere.

### 4. A first step towards rigorous soil mechanics

Terzaghi's theory is the one-dimensional special case of Biot's
poroelasticity. Darcy's law and effective stress can themselves be derived
(from homogenisation and mixture theory), and Cam clay sits inside the
mathematical theory of plasticity. This project starts with the smallest
piece of that structure that can be fully checked.

## What is proved and what is assumed

### The problem, in non-dimensional form

| Symbol | Meaning |
|---|---|
| `Z = z / H` | depth divided by the drainage path length H, so `0 ≤ Z ≤ 1` |
| `T = Tv = cv t / H²` | time factor |
| `u(Z, T)` | excess pore pressure |

Terzaghi's equation `∂u/∂t = cv ∂²u/∂z²` becomes `∂u/∂T = ∂²u/∂Z²`. With
cv and H gone, every result holds for any soil and any layer thickness. That
is why consolidation charts are drawn against Tv.

Boundary conditions, single drainage:

- top, `Z = 0`, drained: `u = 0`
- base, `Z = 1`, impermeable: `∂u/∂Z = 0` (no gradient, so no flow, by Darcy)

One term of the solution is `u = sin(M Z) · exp(−M² T)`, with `M = π(2m + 1)/2`.

### Terzaghi's physical assumptions (not checked by Lean)

The project starts from the governing equation. None of these assumptions is
proved. They are what the equation stands on:

1. The soil is fully saturated.
2. The soil grains and the pore water are incompressible.
3. Flow and strain are vertical only (one-dimensional).
4. Darcy's law holds.
5. Permeability k and the coefficient of volume compressibility mv stay
   constant during consolidation, so cv = k / (mv γw) is constant.
6. Strains are small, so the layer thickness H does not change.
7. The load is applied instantly and stays constant, so the change in total
   stress is zero after loading. This is what allows Δσ′ = −Δu.
8. Secondary compression (creep) is ignored.

Deriving the equation from items 1 to 8 (continuity + Darcy + effective stress
+ the mv stiffness law) is a possible later step. For now it is assumed.

### Progress

| Step | Statement | Status | Where |
|---|---|---|---|
| 1 | Learn Lean basics (*Mathematics in Lean*) | in progress | — |
| 2a | One term satisfies `∂u/∂T = ∂²u/∂Z²` | proved | `consolidation_equation` |
| 2b | One term has zero slope at the impermeable base | proved | `base_impermeable` |
| 2c | One term is zero at the drained top | open: first exercise | `top_drained` |
| 3 | Any finite sum of terms satisfies the equation and both boundaries (superposition) | not started | — |
| 4 | The full infinite series converges and can be differentiated term by term | not started; the hard part | — |
| 5 | Uniqueness of the solution; average degree of consolidation U(Tv) | not started | — |
| — | Derive the equation from assumptions 1 to 8 | possible later step | — |

All proofs are in [TerzaghiLean/OneTerm.lean](TerzaghiLean/OneTerm.lean).
Step 2b is the only place the value of M matters. It needs
cos M = 0, which holds exactly when M = (2k + 1)π/2.

## Building

Needs Lean through elan. The Lean version is pinned in `lean-toolchain`, and
Mathlib in `lakefile.toml`.

```bash
lake exe cache get   # download Mathlib's prebuilt files (about 5 GB)
lake build
```

To work on proofs interactively, open the folder in VS Code with the
"Lean 4" extension. The Lean Infoview panel shows the goal at the cursor.

## References

- Terzaghi, K. (1943). *Theoretical Soil Mechanics*. Wiley. Chapter on the
  theory of consolidation.
- Lean formalisation of PDE topics (heat equation on the whole line):
  [Reservoir listing](https://reservoir.lean-lang.org/@weiran-sun/PDE),
  [source](https://github.com/weiran-sun/pde)
- Lean for PDEs 2025 workshop, heat equation project:
  [Zulip archive](https://leanprover-community.github.io/archive/stream/534314-Lean-for-PDEs-2025/topic/Projects.html)
- State of PDE support in Lean:
  [Zulip thread](https://leanprover-community.github.io/archive/stream/113488-general/topic/Formalization.20of.20PDEs.20in.20Lean.3F.html)
- Avigad, J. and Massot, P. *Mathematics in Lean*. Free online textbook.

## AI use

Proofs are written with help from Claude (Anthropic). Every proof is checked by
Lean's kernel. A proof that Lean accepts is correct whoever wrote it, but the
statements themselves need a human to confirm they say what is intended.

## Licence

[Apache License 2.0](LICENSE), the same licence as Lean and Mathlib.

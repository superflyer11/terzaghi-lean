import Mathlib

/-!
# One term of Terzaghi's 1D consolidation solution

Step 1 of the plan (see README): show that a single separated term satisfies the
consolidation equation and both boundary conditions.

Everything is in non-dimensional form, so no units appear:

* `Z = z / H`  — depth divided by the drainage path length, `0 ≤ Z ≤ 1`
* `T = Tv = cv t / H²` — the time factor
* the equation `∂u/∂t = cv ∂²u/∂z²` becomes `∂u/∂T = ∂²u/∂Z²`

Boundary conditions (single drainage, drained at the top):

* top `Z = 0` drained:          `u = 0`
* base `Z = 1` impermeable:     `∂u/∂Z = 0`  (no flow, by Darcy's law)

The term is `u(Z, T) = sin(M Z) · exp(-M² T)` with `M = π(2m + 1)/2`.
-/

open Real

noncomputable section

namespace Terzaghi

/-- The `m`-th eigenvalue, `M = π(2m + 1)/2`. These are the only values of `M`
for which the sine shape has zero slope at the impermeable base. -/
def M (m : ℕ) : ℝ := π * (2 * m + 1) / 2

/-- One term of Terzaghi's series: excess pore pressure shape `sin(M Z)`,
decaying in time as `exp(-M² T)`. -/
def u (m : ℕ) (Z T : ℝ) : ℝ := sin (M m * Z) * exp (-(M m ^ 2 * T))

/-- Slope of the term with depth: `∂u/∂Z = M cos(M Z) exp(-M² T)`. -/
theorem hasDerivAt_u_Z (m : ℕ) (Z T : ℝ) :
    HasDerivAt (fun Z => u m Z T) (M m * cos (M m * Z) * exp (-(M m ^ 2 * T))) Z := by
  have h : HasDerivAt (fun Z => M m * Z) (M m) Z := by
    simpa using (hasDerivAt_id Z).const_mul (M m)
  unfold u
  have := (h.sin).mul_const (exp (-(M m ^ 2 * T)))
  convert this using 1
  ring

/-- Curvature with depth: `∂²u/∂Z² = -M² sin(M Z) exp(-M² T)`. -/
theorem hasDerivAt_u_ZZ (m : ℕ) (Z T : ℝ) :
    HasDerivAt (fun Z => M m * cos (M m * Z) * exp (-(M m ^ 2 * T)))
      (-(M m ^ 2) * sin (M m * Z) * exp (-(M m ^ 2 * T))) Z := by
  have h : HasDerivAt (fun Z => M m * Z) (M m) Z := by
    simpa using (hasDerivAt_id Z).const_mul (M m)
  have := ((h.cos).const_mul (M m)).mul_const (exp (-(M m ^ 2 * T)))
  convert this using 1
  ring

/-- Rate of change with time: `∂u/∂T = -M² sin(M Z) exp(-M² T)`. -/
theorem hasDerivAt_u_T (m : ℕ) (Z T : ℝ) :
    HasDerivAt (fun T => u m Z T) (-(M m ^ 2) * sin (M m * Z) * exp (-(M m ^ 2 * T))) T := by
  unfold u
  have h : HasDerivAt (fun T => -(M m ^ 2 * T)) (-(M m ^ 2)) T := by
    convert (hasDerivAt_id T).const_mul (-(M m ^ 2)) using 1
    · funext y
      simp
    · simp
  have := (h.exp).const_mul (sin (M m * Z))
  convert this using 1
  ring

/-- **The consolidation equation** `∂u/∂T = ∂²u/∂Z²` holds everywhere. -/
theorem consolidation_equation (m : ℕ) (Z T : ℝ) :
    deriv (fun T => u m Z T) T = deriv (fun Z => deriv (fun Z => u m Z T) Z) Z := by
  have hZ : (fun Z => deriv (fun Z => u m Z T) Z)
      = fun Z => M m * cos (M m * Z) * exp (-(M m ^ 2 * T)) := by
    funext Z
    exact (hasDerivAt_u_Z m Z T).deriv
  rw [hZ, (hasDerivAt_u_T m Z T).deriv, (hasDerivAt_u_ZZ m Z T).deriv]

/-- **Impermeable base**: zero slope `∂u/∂Z = 0` at `Z = 1`, so no flow
crosses the base (Darcy: flow ∝ gradient). This is where the choice of `M` matters. -/
theorem base_impermeable (m : ℕ) (T : ℝ) :
    deriv (fun Z => u m Z T) 1 = 0 := by
  rw [(hasDerivAt_u_Z m 1 T).deriv]
  have hcos : cos (M m) = 0 := by
    rw [cos_eq_zero_iff]
    exact ⟨m, by simp [M]; ring⟩
  simp [hcos]

/-- **Drained top**: zero excess pore pressure at `Z = 0`. -/
theorem top_drained (m : ℕ) (T : ℝ) : u m 0 T = 0 := by
  -- TODO(human)
  sorry

end Terzaghi

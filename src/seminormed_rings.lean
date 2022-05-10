import analysis.normed.normed_field

noncomputable theory

class normed_field' (α : Type*) extends has_norm α, field α, metric_space α :=
(dist_eq : ∀ x y, dist x y = norm (x - y))
(norm_mul : ∀ a b, norm (a * b) ≤ norm a * norm b)

@[priority 100] -- see Note [lower instance priority]
instance normed_field'.to_normed_comm_ring {α : Type*} [normed_field' α] :
  normed_comm_ring α :=
{ norm_mul := λ a b, normed_field'.norm_mul a b,
  ..‹normed_field' α› }

def is_pow_mult {α : Type*} [ring α] (f : α → nnreal) :=
∀ (a : α) {n : ℕ} (hn : 1 ≤ n), f (a^n) = (f a) ^ n

structure is_seminorm {α : Type*} [ring α] (f : α → nnreal) : Prop :=
--(nonneg : ∀ a, 0 ≤ f a)
(zero : f 0 = 0)
(mul : ∀ a b, f (a * b) ≤ f a * f b)
--(one : f 1 ≤ 1)

def is_norm_le_one_class {α : Type*} [ring α] (f : α → nnreal) : Prop := f 1 ≤  1

lemma is_seminorm.pow_le {α : Type*} [ring α] {f : α → nnreal} (hf : is_seminorm f) (a : α) :
  ∀ {n : ℕ}, 0 < n → f (a ^ n) ≤ (f a) ^ n
| 1 h := by simp only [pow_one]
| (n + 2) h := by simpa [pow_succ _ (n + 1)] using le_trans (hf.mul a _)
    (mul_le_mul_left' (is_seminorm.pow_le n.succ_pos) _)

def is_norm_one_class {α : Type*} [ring α] (f : α → nnreal) : Prop := f 1 = 1

lemma is_norm_one_class_iff_nontrivial {α : Type*} [ring α] {f : α → nnreal} (hsn : is_seminorm f)
  (hf1 : f 1 ≤ 1) :
  is_norm_one_class f ↔ ∃ x : α, f x ≠ 0 :=
begin
  rw is_norm_one_class,
  refine ⟨λ h, _, λ h, _⟩,
  { use 1,
    rw h, exact one_ne_zero, },
  { obtain ⟨x, hx⟩ := h,
    by_cases hf0 : f 1 = 0,
    { have hx' : f x ≤ 0,
      { rw ← mul_one x,
        apply le_trans (hsn.mul x 1) _,
        rw [hf0, mul_zero], },
      exact absurd (le_antisymm hx' (f x).2 ) hx, },
    { have h1 : f 1 * 1 ≤ f 1 * f 1,
      { conv_lhs{ rw ← one_mul (1 : α)},
        convert hsn.mul 1 1,
        rw mul_one, },
      rw mul_le_mul_left (lt_of_le_of_ne (zero_le (f 1)) (ne.symm hf0)) at h1,
      exact le_antisymm hf1 h1, }}
end

structure is_norm {α : Type*} [ring α] (f : α → nnreal) extends (is_seminorm f) : Prop :=
(ne_zero : ∀ a, a ≠ 0 → 0 < f a)

structure is_algebra_norm (α : Type*) [comm_ring α] {g : α → nnreal} (hg : is_norm g) 
  {β : Type*} [ring β] [algebra α β] (f : β → nnreal) extends (is_norm f) : Prop :=
(smul : ∀ (a : α) (x : β) , f (a • x) ≤ g a * f x)

def seminorm_extends (α : Type*) [comm_ring α] {g : α → nnreal} (hg : is_seminorm g)
  {β : Type*} [ring β] [algebra α β] (f : β → nnreal) : Prop :=
∀ x : α, f (algebra_map α β x) = g x 

/- structure is_algebra_norm' (α : Type*) [normed_comm_ring α] {β : Type*} [ring β] [algebra α β]
  (f : β → nnreal) extends (is_norm f) : Prop :=
(smul : ∀ (a : α) (x : β) , f (a • x) ≤ ⟨∥ a ∥, norm_nonneg _⟩ * f x) -/

/- def seminorm_extends (α : Type*) [semi_normed_comm_ring α] {β : Type*} [ring β] [algebra α β]
  (f : β → nnreal) : Prop :=
∀ x : α, f (algebra_map α β x) = ⟨∥x∥, norm_nonneg _⟩  -/

def is_nonarchimedean {α : Type*} [ring α] (f : α → nnreal) : Prop := 
∀ a b, f (a + b) ≤ max (f a) (f b)

lemma field.is_norm_of_is_seminorm {α : Type*} [field α] {f : α → nnreal} (hf : is_seminorm f)
  (hnt : ∃ x : α, 0 ≠ f x) : is_norm f := 
{ ne_zero := λ x hx, begin
    obtain ⟨c, hc⟩ := hnt,
    have hfx : 0 ≠ f x,
    { intro h0,
      have hc' : f c ≤ 0,
      { rw [← mul_one c, ← mul_inv_cancel hx, ← mul_assoc, mul_comm c, mul_assoc],
        refine le_trans (hf.mul x _) _,
        rw [← h0, zero_mul] },
      exact hc (ge_antisymm hc' (zero_le (f c))), },
    exact lt_of_le_of_ne (zero_le (f _)) hfx,
  end,
  ..hf }
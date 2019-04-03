import ring_theory.localization
import preliminaries.localisation
import preliminaries.localisation_tests.localization_of

import spectrum_of_a_ring.properties

import sheaves.presheaf_of_rings_on_basis
import sheaves.sheaf_of_rings_on_standard_basis
import sheaves.locally_ringed_space
import spectrum_of_a_ring.spectrum
import spectrum_of_a_ring.zariski_topology
import spectrum_of_a_ring.standard_basis

universe u

open topological_space

local attribute [instance] classical.prop_decidable

noncomputable theory

variables {R : Type u} [comm_ring R]

open localization_alt

section maps

variable {φ : Π (f : R), R → localization.away f}
variable {Hφ : ∀ f, is_ring_hom (φ f)}
variable {Hloc : ∀ f, is_localization_data (powers f) (φ f)}

-- D(g) ⊆ D(f) → f ∈ R[1/g]*

section inverts

include Hloc

lemma localisation_inverts {f g : R} (H : Spec.D'(g) ⊆ Spec.D'(f)) 
: inverts (powers f) (φ g) :=
begin
  rcases (Hloc g) with ⟨Hinv, Hden, Hker⟩,
  rintros ⟨fn, Hfn⟩,
  suffices Hsuff : ∃ si, φ g f * si = 1,
    rcases Hsuff with ⟨si, Hsi⟩,
    show ∃ si, φ g fn * si = 1,
    rcases Hfn with ⟨n, Hfn⟩,
    rw ←Hfn,
    clear Hfn,
    induction n with n Hn,
    { simp,
      rw (is_ring_hom.map_one (φ g)),
      use 1,
      ring, },
    { rw pow_succ,
      rw (is_ring_hom.map_mul (φ g)),
      rcases Hn with ⟨sin, Hn⟩,
      existsi (si * sin),
      rw ←mul_assoc,
      rw mul_assoc _ _ si,
      rw mul_comm _ si,
      rw ←mul_assoc,
      rw Hsi,
      rw one_mul,
      exact Hn, },
  unfold Spec.D' at H,
  rw set.compl_subset_compl at H,
  unfold Spec.V' at H,
  by_contra Hne,
  rw not_exists at Hne,
  have Hnu : ¬is_unit (φ g f),
    intros HC,
    simp [is_unit] at HC,
    rcases HC with ⟨u, HC⟩,
    apply (Hne u.inv),
    rw HC,
    exact u.3,
  let F : ideal (localization.away g) := ideal.span {(φ g f)},
  have HFnT : F ≠ ⊤,
    intros HC,
    rw ideal.span_singleton_eq_top at HC,
    exact (Hnu HC),
  rcases (ideal.exists_le_maximal F HFnT) with ⟨S, ⟨HMS, HFS⟩⟩,
  have HfF : φ g f ∈ F,
    suffices Hsuff : φ g f ∈ {φ g f},
      exact ideal.subset_span Hsuff,
    exact set.mem_singleton _,
  have HfM : φ g f ∈ S := HFS HfF,
  have PS := ideal.is_maximal.is_prime HMS,
  have PS' : ideal.is_prime (ideal.comap (φ g) S)
    := @ideal.is_prime.comap _ _ _ _ (φ g) _ _ PS,
  let S' : Spec R := ⟨ideal.comap (φ g) S, PS'⟩,
  have HfS' : f ∈ S'.val,
    rw ideal.mem_comap,
    exact HfM,
  replace HfS' : S' ∈ {P : Spec R | f ∈ P.val} := HfS',
  have HgS' : g ∈ ideal.comap (φ g) S := H HfS',
  rw ideal.mem_comap at HgS',
  rcases (Hinv ⟨g, ⟨1, by simp⟩⟩) with ⟨w, Hw⟩,
  have HC : φ g g * w ∈ S := ideal.mul_mem_right S HgS',
  erw Hw at HC,
  exact ((ideal.ne_top_iff_one S).1 PS.1) HC,
end

end inverts

lemma localisation_inverts₂ {f g : R} (H : Spec.D'(g) ⊆ Spec.D'(f)) 
: ∃ (a : R) (e : ℕ), g^e = a * f :=
begin 
  have Hinv := @localisation_inverts R _ 
      (λ f, localization.of) (λ f, localization.of.is_ring_hom) 
      (λ f, localization.of.is_localization_data (powers f)) _ _ H,
  rcases (Hinv ⟨f, ⟨1, pow_one f⟩⟩) with ⟨w, Hw⟩,
  dsimp only [subtype.coe_mk] at Hw,
  rcases (quotient.exists_rep w) with ⟨⟨a, ⟨gn, ⟨n, Hn⟩⟩⟩, Hagn⟩,
  erw [←Hagn, quotient.eq] at Hw,
  rcases Hw with ⟨gm, ⟨⟨m, Hm⟩, Hw⟩⟩,
  simp [-sub_eq_add_neg] at Hw,
  rw [sub_mul, sub_eq_zero, mul_assoc, mul_comm f, ←Hn, ←Hm, ←pow_add] at Hw,
  existsi [a * g ^ m, n + m],
  exact Hw,
end

end maps

-- Use this to get a map ψ : Rf → Rg by the universal property.

def S (U : opens (Spec R)) : set R := { r : R | U.1 ⊆ Spec.D'(r) }

instance S.is_submonoid (U : opens (Spec R)) : is_submonoid (S U) :=
{ one_mem := λ ⟨P, PI⟩ HP, ((ideal.ne_top_iff_one P).1 PI.1),
  mul_mem := λ f g Hf Hg,
    begin
      show U.1 ⊆ Spec.D'(f*g),
      exact (Spec.D'.product_eq_inter f g).symm ▸ set.subset_inter Hf Hg,
    end, }

lemma S.rev_mono {U V : opens (Spec R)} (HVU : V ⊆ U) : S U ⊆ S V :=
λ x Hx, set.subset.trans HVU Hx

def φ' (f : R) : R → localization R (S (Spec.DO R (f))) := localization.of

instance φ'.is_ring_hom (f : R) : is_ring_hom (φ' f) := localization.of.is_ring_hom

lemma RS (f : R) : is_localization_data (powers f) (φ' f) :=
begin
  have HfS : f ∈ S (Spec.DO R (f)) := set.subset.refl _,
  refine ⟨_, _, _⟩,
  { rintros ⟨s, Hs⟩,
    have HsS : s ∈ S (Spec.DO R (f)) := (is_submonoid.power_subset HfS) Hs,
    use [⟦⟨1, ⟨s, HsS⟩⟩⟧],
    apply quotient.sound,
    use [1, is_submonoid.one_mem _],
    simp, },
  { intros x,
    have Hx := quotient.exists_rep x,
    rcases (classical.indefinite_description _ Hx) with ⟨⟨p, q⟩, Hpq⟩,
    rcases q with ⟨q, Hq⟩,
    dsimp [S, Spec.DO] at Hq,
    rcases (classical.indefinite_description _ (localisation_inverts₂ Hq)) with ⟨a, Ha⟩,
    rcases (classical.indefinite_description _ Ha) with ⟨e, Hfe⟩,
    use [⟨⟨f^e, ⟨e, rfl⟩⟩, a * p⟩],
    dsimp only [subtype.coe_mk],
    rw [Hfe, ←Hpq],
    apply quotient.sound,
    use [1, is_submonoid.one_mem _],
    dsimp,
    ring, },
  { intros x Hx,
    change localization.of x = 0 at Hx,
    erw quotient.eq at Hx,
    rcases Hx with ⟨s, ⟨Hs, Hx⟩⟩,
    simp at Hx,
    dsimp [S, Spec.DO] at Hs,
    rcases (classical.indefinite_description _ (localisation_inverts₂ Hs)) with ⟨a, Ha⟩,
    rcases (classical.indefinite_description _ Ha) with ⟨e, Hfe⟩,
    use [⟨x, ⟨f^e, ⟨e, rfl⟩⟩⟩],
    { dsimp only [subtype.coe_mk],
      rw Hfe,
      rw mul_comm a,
      rw ←mul_assoc,
      rw Hx,
      rw zero_mul, },
    { refl, } }
end

variable (R)

def structure_presheaf_on_basis : presheaf_of_rings_on_basis (Spec R) (D_fs_basis R) := 
{ -- F(D(f)) = R[1/S] ≅ R[1/f]
  F := λ U BU, localization R (S U),
  res := λ U V BU BV HVU,
    begin
      have H := S.rev_mono HVU,
      apply quotient.lift (λ (x : R × (S U)), ⟦(x.1, (⟨x.2.1, H x.2.2⟩ : (S V)))⟧),
      { rintros ⟨a1, b1, Hb1⟩ ⟨a2, b2, Hb2⟩ ⟨t, Ht, Habt⟩,
        simp,
        use [t, H Ht, Habt], },
    end,
  Hid := λ U BU, funext $ λ x, quotient.induction_on x $ λ a, by simp,
  Hcomp := λ U V W BU BV BW HWV HVU, funext $ λ x, quotient.induction_on x $ λ a, by simp,
  Fring := λ U BU, by apply_instance,
  res_is_ring_hom := λ U V BU BV HVU,
      { map_one := rfl,
        map_add := λ x y, quotient.induction_on₂ x y $ λ ⟨r₁, s₁, hs₁⟩ ⟨r₂, s₂, hs₂⟩, rfl,
        map_mul := λ x y, quotient.induction_on₂ x y $ λ ⟨r₁, s₁, hs₁⟩ ⟨r₂, s₂, hs₂⟩, rfl, }, }

def structure_presheaf : presheaf_of_rings (Spec R) :=
  presheaf_of_rings_on_basis_to_presheaf_of_rings 
    (D_fs_standard_basis R) 
    (structure_presheaf_on_basis R)

import preliminaries.localisation
import sheaves.sheaf_on_standard_basis
import spectrum_of_a_ring.induced_homeomorphism
import spectrum_of_a_ring.structure_presheaf
import spectrum_of_a_ring.structure_sheaf_condition
import spectrum_of_a_ring.structure_sheaf_locality
import spectrum_of_a_ring.structure_sheaf_gluing

universe u

local attribute [instance] classical.prop_decidable

variables {R : Type u} [comm_ring R]

open topological_space
open localization_alt
open localization
open classical

section structure_sheaf 

set_option class.instance_max_depth 100

theorem structure_presheaf_on_basis_is_sheaf_on_basis 
: sheaf_on_standard_basis.is_sheaf_on_standard_basis 
    (D_fs_standard_basis R)
    (structure_presheaf_on_basis R).to_presheaf_on_basis :=
begin
  intros U BU OC,
  have BU' := BU,
  rcases BU' with ⟨f, Hf⟩,

  -- TODO : We prove it for finite covers then extend it.
  have Hγ : fintype OC.γ := sorry,

  -- Lemma: D(f) is open.

  let Rf := localization R (S U),
  have HRf : is_localization (powers f) (localization.of : R → Rf) := sorry, -- Easy

  let g : OC.γ → R := λ i, classical.some (OC.BUis i),
  let Hg : ∀ i, OC.Uis i = Spec.DO R (g i) := λ i, classical.some_spec (OC.BUis i),
  let g' : OC.γ → Rf := λ i, localization.of (g i),
  
  -- Lemma: If ⋃ D(gᵢ) = D(f) then ⋃ D(gᵢ') = Spec Rf.
  have Hcov : (⋃ (λ i, Spec.D'(g' i))) = set.univ,
  { let φ : Spec Rf → Spec R := Zariski.induced localization.of,
    apply set.eq_univ_of_univ_subset,
    rintros P HP,
    have H : φ P ∈ U,
      suffices : φ P ∈ Spec.DO R (f),
        rw Hf,
        exact this,
      show φ P ∈ Spec.D'(f),
      rw ←phi_image_Df HRf,
      use P,
      split,
      { trivial, },
      { refl, },
    rw ←OC.Hcov at H,
    rcases H with ⟨UiS, ⟨⟨UiO, ⟨⟨i, Hi⟩, HUiO⟩⟩, HPUiS⟩⟩,
    use [φ ⁻¹' UiO.val, i],
    { simp,
      rw [←Hi, Hg],
      dsimp only [Spec.DO],
      rw [←Zariski.induced.preimage_D localization.of _], },
    { rw HUiO,
      exact HPUiS, }, },

  -- We want: 1 ∈ <fi>
  let F : set Rf := set.range g',
  replace Hcov : ⋃₀ (Spec.D' '' F) = set.univ := sorry, -- Easy
  rw (Spec.D'.union F) at Hcov,
  replace Hcov : Spec.V F = ∅ := sorry, -- Easy
  rw Spec.V.set_eq_span at Hcov,
  rw Spec.V.empty_iff_ideal_top at Hcov,
  rw ideal.eq_top_iff_one at Hcov,
  
  -- Now we can apply covering lemmas.

  let αi := λ i, structure_presheaf_on_basis.res BU (OC.BUis i) (subset_covering i),
  let Rfi := λ i, localization R (S (OC.Uis i)),

  have Hlocres : Π i, is_localization_data (powers (g' i)) (αi i) 
    := λ i, structure_presheaf.res.localization BU (OC.BUis i) (subset_covering i),

  have Hsc₁ := 
    @standard_covering₁ Rf _ _ Hγ g' Rfi _ αi _ Hlocres Hcov,
    -- _ _ Hγ OC.Uis Rfis _ αi _ 
      --(λ i, structure_presheaf.localization (OC.BUis i)),

  let Rfij := λ i j, localization R (S ((OC.Uis i) ∩ (OC.Uis j))),

  let βij := 
    λ i j, structure_presheaf_on_basis.res_to_inter BU (OC.BUis i) (OC.BUis j) (subset_covering i),

  have Hlocres_to_inter 
    := λ i j, structure_presheaf.res_to_inter.localization 
        BU (OC.BUis i) (OC.BUis j) (subset_covering i),

  have Hsc₂ :=
    @standard_covering₂ Rf _ _ Hγ g' Rfi _ αi _ Hlocres Rfij _ βij _ Hlocres_to_inter Hcov,

  constructor,
  { intros s t Hst,
    dunfold structure_presheaf_on_basis at s,
    dunfold structure_presheaf_on_basis at t,
    dsimp [coe_fn, has_coe_to_fun.coe] at s,
    dsimp [coe_fn, has_coe_to_fun.coe] at t,

    let α' := @α Rf _ _ Hγ Rfi _ αi _,

    suffices Hsuff : α' s = α' t,
      exact (Hsc₁ Hsuff),

    apply funext,
    intros i,
    dsimp [α'],
    simp [α, αi],

    replace Hst := Hst i,
    rw ←structure_presheaf_on_basis.res_eq,
    exact Hst,
    },
  { -- Gluing
    intros s,
    
    intros Hs,

    have H := (Hsc₂ s).1,

    let β' := @β Rf _ _ Hγ g' Rfi _ αi _ Hlocres Rfij _ βij _ Hlocres_to_inter,

    have : β' s = 0,
      simp [β', β, -sub_eq_add_neg, sub_eq_zero, β1, β2],
      apply funext, intro j,
      apply funext, intro k,
      have H' := Hs j k,
      dsimp at H',
      rw structure_presheaf_on_basis.res_eq at H',
      --dsimp [structure_presheaf_on_basis.res] at H',
      
      have evox1 : βij j k = (structure_presheaf_on_basis.res 
              (OC.BUis j)
              ((D_fs_standard_basis R).2 (OC.BUis j) (OC.BUis k)) 
              (set.inter_subset_left (OC.Uis j) (OC.Uis k))) ∘ (αi j),
        dsimp [αi, βij, structure_presheaf_on_basis.res_to_inter],
        erw ←structure_presheaf_on_basis.res_comp,
        refl,

      have Hunique1 
        := is_localization_unique' 
            (powers (g' j)) 
            (αi j) 
            (Hlocres j)
            (structure_presheaf_on_basis.res 
              (OC.BUis j)
              ((D_fs_standard_basis R).2 (OC.BUis j) (OC.BUis k)) 
              (set.inter_subset_left (OC.Uis j) (OC.Uis k)))
            (s j)
            (βij j k)
            (@inverts_powers2 Rf _ _ Hγ g' Rfij _ βij _ Hlocres_to_inter j k)
            evox1,

      rw Hunique1,
            
      have evox2 : βij j k = (structure_presheaf_on_basis.res 
              (OC.BUis k)
              ((D_fs_standard_basis R).2 (OC.BUis j) (OC.BUis k)) 
              (set.inter_subset_right (OC.Uis j) (OC.Uis k))) ∘ (αi k),
        dsimp [αi, βij, structure_presheaf_on_basis.res_to_inter],
        erw ←structure_presheaf_on_basis.res_comp,
        refl,

      have Hunique2 
        := is_localization_unique' 
            (powers (g' k)) 
            (αi k) 
            (Hlocres k)
            (structure_presheaf_on_basis.res 
              (OC.BUis k)
              ((D_fs_standard_basis R).2 (OC.BUis j) (OC.BUis k)) 
              (set.inter_subset_right (OC.Uis j) (OC.Uis k)))
            (s k)
            (βij j k)
            (@inverts_powers1 Rf _ _ Hγ g' Rfij _ βij _ Hlocres_to_inter j k)
            evox2,

      rw Hunique2,
      exact H'.symm,

    have H''' := H this,
    rcases H''' with ⟨S, HS⟩,
    use S,
    intros i,
    replace HS := (congr_fun HS) i,
    dsimp [α, αi] at HS,
    rw structure_presheaf_on_basis.res_eq,
    exact HS,
    
   }
end

end structure_sheaf 

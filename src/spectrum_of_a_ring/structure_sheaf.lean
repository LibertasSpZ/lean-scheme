import topology.basic
import preliminaries.localisation
import sheaves.sheaf_on_standard_basis
import spectrum_of_a_ring.induced_homeomorphism
import spectrum_of_a_ring.quasi_compact
import spectrum_of_a_ring.structure_presheaf
import spectrum_of_a_ring.structure_sheaf_condition
import spectrum_of_a_ring.structure_sheaf_locality
import spectrum_of_a_ring.structure_sheaf_gluing

universes u v

local attribute [instance] classical.prop_decidable

variables {R : Type u} [comm_ring R]

open topological_space
open localization_alt
open localization
open classical

section structure_sheaf 

-- D(f) = ⋃i=1,..,n D(gi)

lemma lemma_standard_open
{U : opens (Spec R)} (BU : U ∈ D_fs R) (OC : covering_standard_basis (D_fs R) (Spec.DO R (some BU))) 
: ∃ (γf : Type u) (Hf : fintype γf) (ρ : γf → OC.γ),
Spec.DO R (some BU) ⊆ ⋃ (λ i, Spec.DO R (some (OC.BUis (ρ i)))) :=
begin
  let f := some BU,
  let Rf := localization R (S U),
  have Hf : U.1 = Spec.D' f,
    rw some_spec BU,
    simp [f, Spec.DO], 
  have HOCUis : ∀ i, OC.Uis i = Spec.DO R (some (OC.BUis i)),
      intros i,
      rw ←some_spec (OC.BUis i),

  have HRf : is_localization_data (powers f) (localization.of : R → Rf) 
     := structure_presheaf.localization BU,
  let g : R → Rf := of,
  let φ : Spec Rf → Spec R := Zariski.induced g,
  have Hcompact := Spec.quasi_compact.aux Rf,

  have HcompactDf : compact (Spec.D' f),
    rw ←phi_image_Df HRf,
    exact compact_image Hcompact (Zariski.induced.continuous g), 
  
  let Uis : set (set (Spec R)) := set.range (subtype.val ∘ OC.Uis),
  have OUis : ∀ (t : set (Spec R)), t ∈ Uis → is_open t,
    intros t Ht,
    rcases Ht with ⟨i, Ht⟩,
    rw ←Ht,
    simp,
    exact (OC.Uis i).2,
  have HUis : ⋃₀ Uis = (⋃ OC.Uis).val,
    simp,
    apply set.ext,
    intros x,
    split,
    { rintros ⟨Ui, ⟨⟨i, HUi⟩, HxUi⟩⟩,
      exact ⟨Ui, ⟨OC.Uis i, ⟨⟨i, rfl⟩, HUi⟩⟩, HxUi⟩, },
    { rintros ⟨Ui, ⟨OUi, ⟨⟨i, HOUi⟩, HUi⟩⟩, HxUi⟩,
      rw ←HOUi at HUi,
      exact ⟨Ui, ⟨⟨i, HUi⟩, HxUi⟩⟩, },
  have HDfUis : Spec.D' f ⊆ ⋃₀ Uis,
    rw [HUis, OC.Hcov],
    simp [f, Spec.DO, set.subset.refl],
  have Hfincov 
    := @compact_elim_finite_subcover (Spec R) _ (Spec.D' f) Uis HcompactDf OUis HDfUis,

  rcases Hfincov with ⟨Uis', HUis', ⟨HfinUis', Hfincov⟩⟩,

  have HUis'fintype := set.finite.fintype HfinUis',
  let ρ : Uis' → OC.γ := λ V, some (HUis' V.2),
  use [Uis', HUis'fintype, ρ],

  intros x Hx,
  dsimp only [Spec.DO] at Hx,
  replace Hx := Hfincov Hx,
  rcases Hx with ⟨Ui, ⟨HUi', HxUi⟩⟩,
  use Ui,
  have HUi : Ui ∈ subtype.val '' set.range (λ (i : Uis'), Spec.DO R (some (OC.BUis (ρ i)))),
    use [OC.Uis (ρ ⟨Ui, HUi'⟩)],
    split,
    { use ⟨Ui, HUi'⟩,
      dsimp [ρ],
      rw ←HOCUis (ρ ⟨Ui, HUi'⟩), },
    { exact some_spec (HUis' HUi'), },
  use HUi,
  exact HxUi,
end

theorem structure_presheaf_on_basis_is_compact
: sheaf_on_standard_basis.basis_is_compact (D_fs_standard_basis R) :=
begin
  rintros U BU ⟨⟨γ, Uis, Hcov⟩, BUis⟩,
  dsimp only [subtype.coe_mk] at *,
  rw some_spec BU at Hcov,
  rcases (lemma_standard_open BU ⟨⟨Uis, Hcov⟩, BUis⟩) with ⟨γf, Hγf, ρ, H⟩,
  use [γf, Hγf, ρ],
  apply le_antisymm,
  { intros x Hx,
    rcases Hx with ⟨Ui, ⟨⟨OUi, ⟨⟨i, Hi⟩, HUival⟩⟩, HxUi⟩⟩,
    dsimp at Hi,
    rw ←some_spec BU at Hcov,
    rw ←Hcov,
    rw ←Hi at HUival,
    use [Ui, ⟨Uis (ρ i), ⟨⟨ρ i, rfl⟩, HUival⟩⟩, HxUi], },
  { have HUis : Uis = λ i, Spec.DO R (some (BUis i)),
      apply funext,
      intros i,
      rw ←some_spec (BUis i),
    rw HUis,
    dsimp [function.comp],
    rw some_spec BU,
    exact H, },
end

theorem structure_presheaf_on_basis_is_sheaf_on_standard_basis_cofinal_system
: sheaf_on_standard_basis.is_sheaf_on_standard_basis_cofinal_system
    (D_fs_standard_basis R)
    (structure_presheaf_on_basis R).to_presheaf_on_basis :=
begin
  intros U BU OC Hγ,
  let f := some BU,
  let Rf := localization R (S U),
  have HRf : is_localization_data (powers f) (localization.of : R → Rf) 
    := structure_presheaf.localization BU,

  let fi := λ i, some (OC.BUis i),
  sorry,
end

theorem structure_presheaf_on_basis_is_sheaf_on_basis 
: sheaf_on_standard_basis.is_sheaf_on_standard_basis 
    (D_fs_standard_basis R)
    (structure_presheaf_on_basis R).to_presheaf_on_basis :=
begin
  
  apply sheaf_on_standard_basis.cofinal_systems_coverings_standard_case,
  { apply structure_presheaf_on_basis_is_compact, },

  --

  intros U BU OC Hγ,
  let f := some BU,
  let Rf := localization R (S U),
  have HRf : is_localization_data (powers f) (localization.of : R → Rf) 
    := structure_presheaf.localization BU,

  -- TODO : We prove it for finite covers then extend it.
  have Hγ : fintype OC.γ := sorry,

  -- Lemma: D(f) is open.

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
        rw some_spec BU,
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

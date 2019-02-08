/-
    Stalk of rings.

    https://stacks.math.columbia.edu/tag/007L
    (just says that the category of rings is a type of algebraic structure)
-/

import sheaves.stalk
import sheaves.presheaf_of_rings

universe u 

section stalk_of_rings

variables {α : Type u} [topological_space α] 
variables (F : presheaf_of_rings α) (x : α)

definition stalk_of_rings := stalk F.to_presheaf x

end stalk_of_rings
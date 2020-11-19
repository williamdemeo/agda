{-# OPTIONS --without-K --exact-split --allow-unsolved-metas #-}
module book.18-finite-types where

import book.17-set-quotients
open book.17-set-quotients public

{- Counting in type theory -}

count : {l : Level} → UU l → UU l
count X = Σ ℕ (λ k → Fin k ≃ X)

number-of-elements-count : {l : Level} {X : UU l} → count X → ℕ
number-of-elements-count = pr1

equiv-count :
  {l : Level} {X : UU l} (e : count X) → Fin (number-of-elements-count e) ≃ X
equiv-count = pr2

map-equiv-count :
  {l : Level} {X : UU l} (e : count X) → Fin (number-of-elements-count e) → X
map-equiv-count e = map-equiv (equiv-count e)

map-inv-equiv-count :
  {l : Level} {X : UU l} (e : count X) → X → Fin (number-of-elements-count e)
map-inv-equiv-count e = map-inv-equiv (equiv-count e)

{- We show that count is closed under equivalences -}

abstract
  equiv-count-equiv :
    {l1 l2 : Level} {X : UU l1} {Y : UU l2} (e : X ≃ Y) (f : count X) →
    Fin (number-of-elements-count f) ≃ Y
  equiv-count-equiv e f = e ∘e (equiv-count f)

count-equiv :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} (e : X ≃ Y) → count X → count Y
count-equiv e f =
  pair (number-of-elements-count f) (equiv-count-equiv e f)

count-equiv' :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} (e : X ≃ Y) → count Y → count X
count-equiv' e = count-equiv (inv-equiv e)

count-is-equiv :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} {f : X → Y} →
  is-equiv f → count X → count Y
count-is-equiv is-equiv-f = count-equiv (pair _ is-equiv-f)

count-is-equiv' :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} {f : X → Y} →
  is-equiv f → count Y → count X
count-is-equiv' is-equiv-f = count-equiv' (pair _ is-equiv-f)

{- Types with a count have decidable equality -}

has-decidable-equality-count :
  {l : Level} {X : UU l} → count X → has-decidable-equality X
has-decidable-equality-count (pair k e) =
  has-decidable-equality-equiv' e has-decidable-equality-Fin

{- Fin k has a count -}

count-Fin : (k : ℕ) → count (Fin k)
count-Fin k = pair k equiv-id

{- A type as 0 elements if and only if it is empty -}

is-empty-is-zero-number-of-elements-count :
  {l : Level} {X : UU l} (e : count X) →
  is-zero-ℕ (number-of-elements-count e) → is-empty X
is-empty-is-zero-number-of-elements-count (pair .zero-ℕ e) refl x =
  map-inv-equiv e x

is-zero-number-of-elements-count-is-empty :
  {l : Level} {X : UU l} (e : count X) →
  is-empty X → is-zero-ℕ (number-of-elements-count e)
is-zero-number-of-elements-count-is-empty (pair zero-ℕ e) H = refl
is-zero-number-of-elements-count-is-empty (pair (succ-ℕ k) e) H =
  ex-falso (H (map-equiv e zero-Fin))

count-is-empty :
  {l : Level} {X : UU l} → is-empty X → count X
count-is-empty H =
  pair zero-ℕ (inv-equiv (pair H (is-equiv-is-empty' H)))

count-empty : count empty
count-empty = count-Fin zero-ℕ

{- A type has 1 element if and only if it is contractible -}

count-is-contr :
  {l : Level} {X : UU l} → is-contr X → count X
count-is-contr H = pair one-ℕ (equiv-is-contr is-contr-Fin-one-ℕ H)

is-contr-is-one-number-of-elements-count :
  {l : Level} {X : UU l} (e : count X) →
  is-one-ℕ (number-of-elements-count e) → is-contr X
is-contr-is-one-number-of-elements-count (pair .(succ-ℕ zero-ℕ) e) refl =
  is-contr-equiv' (Fin one-ℕ) e is-contr-Fin-one-ℕ

is-one-number-of-elements-count-is-contr :
  {l : Level} {X : UU l} (e : count X) →
  is-contr X → is-one-ℕ (number-of-elements-count e)
is-one-number-of-elements-count-is-contr (pair k e) H =
  is-injective-Fin (equiv-is-contr H is-contr-Fin-one-ℕ ∘e e)

count-unit : count unit
count-unit = count-is-contr is-contr-unit

{- We can count the elements of an identity type of a type that has decidable
   equality. -}

count-Eq-has-decidable-equality' :
  {l : Level} {X : UU l} {x y : X} (d : is-decidable (Id x y)) →
  count (Eq-has-decidable-equality' x y d)
count-Eq-has-decidable-equality' {l} {X} {x} {y} (inl p) = count-unit
count-Eq-has-decidable-equality' {l} {X} {x} {y} (inr f) = count-empty

count-Eq-has-decidable-equality :
  {l : Level} {X : UU l} (d : has-decidable-equality X) {x y : X} →
  count (Eq-has-decidable-equality d x y)
count-Eq-has-decidable-equality d {x} {y} =
  count-Eq-has-decidable-equality' (d x y)

count-eq :
  {l : Level} {X : UU l} → has-decidable-equality X → {x y : X} → count (Id x y)
count-eq d {x} {y} =
  count-equiv
    ( equiv-prop
      ( is-prop-Eq-has-decidable-equality d)
      ( is-set-has-decidable-equality d x y)
      ( eq-Eq-has-decidable-equality d)
      ( Eq-has-decidable-equality-eq d))
    ( count-Eq-has-decidable-equality d)

{- Types equipped with a count are closed under coproducts -}

count-coprod :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} →
  count X → count Y → count (coprod X Y)
count-coprod (pair k e) (pair l f) =
  pair
    ( add-ℕ k l)
    ( ( equiv-coprod e f) ∘e
      ( inv-equiv (coprod-Fin k l)))

{- Types equipped with a count are closed under Σ-types -}

count-Σ' :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
  (k : ℕ) (e : Fin k ≃ A) → ((x : A) → count (B x)) → count (Σ A B)
count-Σ' zero-ℕ e f =
  count-is-empty
    ( λ x → is-empty-is-zero-number-of-elements-count (pair zero-ℕ e) refl (pr1 x))
count-Σ' {l1} {l2} {A} {B} (succ-ℕ k) e f =
  count-equiv
    ( ( equiv-Σ-equiv-base B e) ∘e
      ( ( inv-equiv
          ( right-distributive-Σ-coprod (Fin k) unit (B ∘ map-equiv e))) ∘e
        ( equiv-coprod
          ( equiv-id)
          ( inv-equiv
            ( left-unit-law-Σ (B ∘ (map-equiv e ∘ inr)))))))
    ( count-coprod
      ( count-Σ' k equiv-id (λ x → f (map-equiv e (inl x))))
      ( f (map-equiv e (inr star))))

abstract
  equiv-count-Σ' :
    {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
    (k : ℕ) (e : Fin k ≃ A) (f : (x : A) → count (B x)) →
    Fin (number-of-elements-count (count-Σ' k e f)) ≃ Σ A B
  equiv-count-Σ' k e f = pr2 (count-Σ' k e f)

count-Σ :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
  count A → ((x : A) → count (B x)) → count (Σ A B)
count-Σ (pair k e) f =
  pair (number-of-elements-count (count-Σ' k e f)) (equiv-count-Σ' k e f)

count-fiber-count-Σ :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
  count A → count (Σ A B) → (x : A) → count (B x)
count-fiber-count-Σ {B = B} e f x =
  count-equiv
    ( equiv-fib-pr1 x)
    ( count-Σ f
      ( λ z → count-eq (has-decidable-equality-count e)))

equiv-total-fib-map-section :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} (b : (x : A) → B x) →
  Σ (Σ A B) (fib (map-section b)) ≃ A
equiv-total-fib-map-section b = equiv-total-fib (map-section b)

count-fib-map-section :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} (b : (x : A) → B x) →
  count (Σ A B) → ((x : A) → count (B x)) →
  (t : Σ A B) → count (fib (map-section b) t)
count-fib-map-section {l1} {l2} {A} {B} b e f (pair y z) =
  count-equiv'
    ( ( ( left-unit-law-Σ-is-contr
            ( is-contr-total-path' y)
            ( pair y refl)) ∘e
        ( inv-assoc-Σ A
          ( λ x → Id x y)
          ( λ t → Id (tr B (pr2 t) (b (pr1 t))) z))) ∘e
      ( equiv-tot (λ x → equiv-pair-eq-Σ (pair x (b x)) (pair y z))))
    ( count-eq (has-decidable-equality-count (f y)))

count-base-count-Σ :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} (b : (x : A) → B x) →
  count (Σ A B) → ((x : A) → count (B x)) → count A
count-base-count-Σ b e f =
  count-equiv
    ( equiv-total-fib-map-section b)
    ( count-Σ e (count-fib-map-section b e f))

section-count-base-count-Σ' :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} → count (Σ A B) →
  (f : (x : A) → count (B x)) →
  count (Σ A (λ x → is-zero-ℕ (number-of-elements-count (f x)))) →
  (x : A) → coprod (B x) (is-zero-ℕ (number-of-elements-count (f x)))
section-count-base-count-Σ' e f g x with
  is-decidable-is-zero-ℕ (number-of-elements-count (f x))
... | inl p = inr p
... | inr H with is-successor-is-nonzero-ℕ H
... | (pair k p) = inl (map-equiv-count (f x) (tr Fin (inv p) zero-Fin))

count-base-count-Σ' :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} → count (Σ A B) →
  (f : (x : A) → count (B x)) →
  count (Σ A (λ x → is-zero-ℕ (number-of-elements-count (f x)))) → count A
count-base-count-Σ' {l1} {l2} {A} {B} e f g =
  count-base-count-Σ
    ( section-count-base-count-Σ' e f g)
    ( count-equiv'
      ( left-distributive-Σ-coprod A B
        ( λ x → is-zero-ℕ (number-of-elements-count (f x))))
      ( count-coprod e g))
    ( λ x → count-coprod (f x) (count-eq has-decidable-equality-ℕ))

{- A coproduct X + Y has a count if and only if both X and Y have a count -}

is-left : {l1 l2 : Level} {X : UU l1} {Y : UU l2} → coprod X Y → UU lzero
is-left (inl x) = unit
is-left (inr x) = empty

equiv-left-summand :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} → (Σ (coprod X Y) is-left) ≃ X
equiv-left-summand {l1} {l2} {X} {Y} =
  ( ( right-unit-law-coprod X) ∘e
    ( equiv-coprod right-unit-law-prod (right-absorption-prod Y))) ∘e
  ( right-distributive-Σ-coprod X Y is-left)

count-is-left :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} (t : coprod X Y) → count (is-left t)
count-is-left (inl x) = count-unit
count-is-left (inr x) = count-empty

count-left-summand :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} → count (coprod X Y) → count X
count-left-summand e = count-equiv equiv-left-summand (count-Σ e count-is-left)

is-right : {l1 l2 : Level} {X : UU l1} {Y : UU l2} → coprod X Y → UU lzero
is-right (inl x) = empty
is-right (inr x) = unit

equiv-right-summand :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} → (Σ (coprod X Y) is-right) ≃ Y
equiv-right-summand {l1} {l2} {X} {Y} =
  ( ( left-unit-law-coprod Y) ∘e
    ( equiv-coprod (right-absorption-prod X) right-unit-law-prod)) ∘e
    ( right-distributive-Σ-coprod X Y is-right)

count-is-right :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} (t : coprod X Y) → count (is-right t)
count-is-right (inl x) = count-empty
count-is-right (inr x) = count-unit

count-right-summand :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} → count (coprod X Y) → count Y
count-right-summand e =
  count-equiv equiv-right-summand (count-Σ e count-is-right)

{- Maybe X has a count if and only if X has a count -}

count-Maybe : {l : Level} {X : UU l} → count X → count (Maybe X)
count-Maybe {l} {X} e = count-coprod e count-unit

is-nonzero-number-of-elements-count-Maybe :
  {l : Level} {X : UU l} (e : count (Maybe X)) →
  is-nonzero-ℕ (number-of-elements-count e)
is-nonzero-number-of-elements-count-Maybe e p =
  is-empty-is-zero-number-of-elements-count e p exception-Maybe

is-successor-number-of-elements-count-Maybe :
  {l : Level} {X : UU l} (e : count (Maybe X)) →
  is-successor-ℕ (number-of-elements-count e)
is-successor-number-of-elements-count-Maybe e =
  is-successor-is-nonzero-ℕ (is-nonzero-number-of-elements-count-Maybe e)

count-count-Maybe :
  {l : Level} {X : UU l} → count (Maybe X) → count X
count-count-Maybe (pair k e) with
  is-successor-number-of-elements-count-Maybe (pair k e)
... | pair l refl = pair l (equiv-equiv-Maybe e)

{- X × Y has a count if and only if Y → count X and X → count Y -}

count-prod :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} → count X → count Y → count (X × Y)
count-prod (pair k e) (pair l f) =
  pair
    ( mul-ℕ k l)
    ( ( equiv-prod e f) ∘e
      ( inv-equiv (prod-Fin k l)))

equiv-left-factor :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} (y : Y) →
  (Σ (X × Y) (λ t → Id (pr2 t) y)) ≃ X
equiv-left-factor {l1} {l2} {X} {Y} y =
  ( ( right-unit-law-prod) ∘e
    ( equiv-tot
      ( λ x → equiv-is-contr (is-contr-total-path' y) is-contr-unit))) ∘e
  ( assoc-Σ X (λ x → Y) (λ t → Id (pr2 t) y))

count-left-factor :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} → count (X × Y) → Y → count X
count-left-factor e y =
  count-equiv
    ( equiv-left-factor y)
    ( count-Σ e
      ( λ z →
        count-eq
          ( has-decidable-equality-right-factor
            ( has-decidable-equality-count e)
            ( pr1 z))))

count-right-factor :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} → count (X × Y) → X → count Y
count-right-factor e x =
  count-left-factor (count-equiv commutative-prod e) x

count-decidable-Prop :
  {l1 : Level} (P : UU-Prop l1) →
  is-decidable (type-Prop P) → count (type-Prop P)
count-decidable-Prop P (inl p) =
  count-is-contr (is-proof-irrelevant-is-prop (is-prop-type-Prop P) p)
count-decidable-Prop P (inr f) = count-is-empty f

count-decidable-subtype :
  {l1 l2 : Level} {X : UU l1} (P : X → UU-Prop l2) →
  ((x : X) → is-decidable (type-Prop (P x))) →
  count X → count (Σ X (λ x → type-Prop (P x)))
count-decidable-subtype P d e =
  count-Σ e (λ x → count-decidable-Prop (P x) (d x))

is-decidable-count :
  {l : Level} {X : UU l} → count X → is-decidable X
is-decidable-count (pair zero-ℕ e) =
  inr (is-empty-is-zero-number-of-elements-count (pair zero-ℕ e) refl)
is-decidable-count (pair (succ-ℕ k) e) =
  inl (map-equiv e zero-Fin)

is-decidable-count-Σ :
  {l1 l2 : Level} {X : UU l1} {P : X → UU l2} →
  count X → count (Σ X P) → (x : X) → is-decidable (P x)
is-decidable-count-Σ e f x =
  is-decidable-count (count-fiber-count-Σ e f x)

is-decidable-count-subtype :
  {l1 l2 : Level} {X : UU l1} (P : X → UU-Prop l2) → count X →
  count (Σ X (λ x → type-Prop (P x))) → (x : X) → is-decidable (type-Prop (P x))
is-decidable-count-subtype P = is-decidable-count-Σ

----------

leq-count :
  {l : Level} {X : UU l} → count X → X → X → UU lzero
leq-count e x y =
  leq-Fin (map-inv-equiv-count e x) (map-inv-equiv-count e y)

refl-leq-count :
  {l : Level} {X : UU l} (e : count X) (x : X) → leq-count e x x
refl-leq-count (pair k e) x = refl-leq-Fin (map-inv-equiv e x)

antisymmetric-leq-count :
  {l : Level} {X : UU l} (e : count X) {x y : X} →
  leq-count e x y → leq-count e y x → Id x y
antisymmetric-leq-count (pair k e) H K =
  is-injective-map-inv-equiv e (antisymmetric-leq-Fin H K)

transitive-leq-count :
  {l : Level} {X : UU l} (e : count X) {x y z : X} →
  leq-count e x y → leq-count e y z → leq-count e x z
transitive-leq-count (pair k e) {x} {y} {z} H K =
  transitive-leq-Fin {x = map-inv-equiv e x} {map-inv-equiv e y} H K

preserves-leq-equiv-count :
  {l : Level} {X : UU l} (e : count X)
  {x y : Fin (number-of-elements-count e)} →
  leq-Fin x y → leq-count e (map-equiv-count e x) (map-equiv-count e y)
preserves-leq-equiv-count e {x} {y} H =
  concatenate-eq-leq-eq-Fin
    ( isretr-map-inv-equiv (equiv-count e) x)
    ( H)
    ( inv (isretr-map-inv-equiv (equiv-count e) y))

reflects-leq-equiv-count :
  {l : Level} {X : UU l} (e : count X)
  {x y : Fin (number-of-elements-count e)} →
  leq-count e (map-equiv-count e x) (map-equiv-count e y) → leq-Fin x y
reflects-leq-equiv-count e {x} {y} H =
  concatenate-eq-leq-eq-Fin
    ( inv (isretr-map-inv-equiv (equiv-count e) x))
    ( H)
    ( isretr-map-inv-equiv (equiv-count e) y)

transpose-leq-equiv-count :
  {l : Level} {X : UU l} (e : count X) →
  {x : Fin (number-of-elements-count e)} {y : X} →
  leq-Fin x (map-inv-equiv-count e y) → leq-count e (map-equiv-count e x) y
transpose-leq-equiv-count e {x} {y} H =
  concatenate-eq-leq-eq-Fin
    ( isretr-map-inv-equiv (equiv-count e) x)
    ( H)
    ( refl)

transpose-leq-equiv-count' :
  {l : Level} {X : UU l} (e : count X) →
  {x : X} {y : Fin (number-of-elements-count e)} →
  leq-Fin (map-inv-equiv-count e x) y → leq-count e x (map-equiv-count e y)
transpose-leq-equiv-count' e {x} {y} H =
  concatenate-eq-leq-eq-Fin
    ( refl)
    ( H)
    ( inv (isretr-map-inv-equiv (equiv-count e) y))

is-lower-bound-count :
  {l1 l2 : Level} {A : UU l1} → count A → (A → UU l2) → A → UU (l1 ⊔ l2)
is-lower-bound-count {l1} {l2} {A} e B a = (x : A) → B x → leq-count e a x

first-element-count :
  {l1 l2 : Level} {A : UU l1} (e : count A) (B : A → UU l2) → UU (l1 ⊔ l2)
first-element-count {l1} {l2} {A} e B =
  Σ A (λ x → (B x) × is-lower-bound-count e B x)

first-element-is-decidable-subtype-count :
  {l1 l2 : Level} {A : UU l1} (e : count A) {B : A → UU l2} →
  ((x : A) → is-decidable (B x)) → ((x : A) → is-prop (B x)) →
  Σ A B → first-element-count e B
first-element-is-decidable-subtype-count (pair k e) {B} d H (pair a b) =
  map-Σ
    ( λ x → (B x) × is-lower-bound-count (pair k e) B x)
    ( map-equiv e)
    ( λ x → map-prod {B = is-lower-bound-Fin (B ∘ map-equiv e) x} id
      ( λ L y b →
        transpose-leq-equiv-count
          ( pair k e)
          ( L (map-inv-equiv e y) (tr B (inv (issec-map-inv-equiv e y)) b))))
    ( minimal-element-decidable-subtype-Fin
      ( λ x → d (map-equiv e x))
      ( pair (map-inv-equiv e a) (tr B (inv (issec-map-inv-equiv e a)) b)))

--------------------------------------------------------------------------------

-- Section 15.3 Finite types

{- Definition -}

is-finite-Prop :
  {l : Level} → UU l → UU-Prop l
is-finite-Prop X = trunc-Prop (count X)

is-finite :
  {l : Level} → UU l → UU l
is-finite X = type-Prop (is-finite-Prop X)

is-prop-is-finite :
  {l : Level} (X : UU l) → is-prop (is-finite X)
is-prop-is-finite X = is-prop-type-Prop (is-finite-Prop X)

is-finite-count :
  {l : Level} {X : UU l} → count X → is-finite X
is-finite-count = unit-trunc-Prop

𝔽 : UU (lsuc lzero)
𝔽 = Σ (UU lzero) is-finite

type-𝔽 : 𝔽 → UU lzero
type-𝔽 X = pr1 X

is-finite-type-𝔽 : (X : 𝔽) → is-finite (type-𝔽 X)
is-finite-type-𝔽 X = pr2 X

is-finite-equiv :
  {l1 l2 : Level} {A : UU l1} {B : UU l2} (e : A ≃ B) →
  is-finite A → is-finite B
is-finite-equiv e =
  map-universal-property-trunc-Prop
    ( is-finite-Prop _)
    ( is-finite-count ∘ (count-equiv e))

is-finite-is-equiv :
  {l1 l2 : Level} {A : UU l1} {B : UU l2} {f : A → B} →
  is-equiv f → is-finite A → is-finite B
is-finite-is-equiv is-equiv-f =
  map-universal-property-trunc-Prop
    ( is-finite-Prop _)
    ( is-finite-count ∘ (count-equiv (pair _ is-equiv-f)))

is-finite-equiv' :
  {l1 l2 : Level} {A : UU l1} {B : UU l2} (e : A ≃ B) →
  is-finite B → is-finite A
is-finite-equiv' e = is-finite-equiv (inv-equiv e)

{- Theorem -}

mere-equiv :
  {l1 l2 : Level} → UU l1 → UU l2 → UU (l1 ⊔ l2)
mere-equiv X Y = type-trunc-Prop (X ≃ Y)

has-finite-cardinality :
  {l : Level} → UU l → UU l
has-finite-cardinality X = Σ ℕ (λ k → mere-equiv (Fin k) X)

number-of-elements-has-finite-cardinality :
  {l : Level} {X : UU l} → has-finite-cardinality X → ℕ
number-of-elements-has-finite-cardinality = pr1

mere-equiv-has-finite-cardinality :
  {l : Level} {X : UU l} (c : has-finite-cardinality X) →
  type-trunc-Prop (Fin (number-of-elements-has-finite-cardinality c) ≃ X)
mere-equiv-has-finite-cardinality = pr2

is-prop-has-finite-cardinality' :
  {l1 : Level} {X : UU l1} → is-prop' (has-finite-cardinality X)
is-prop-has-finite-cardinality' {l1} {X} (pair k K) (pair l L) =
  eq-subtype
    ( λ k → is-prop-type-trunc-Prop)
    ( apply-universal-property-trunc-Prop K
      ( pair (Id k l) (is-set-ℕ k l))
      ( λ (e : Fin k ≃ X) →
        map-universal-property-trunc-Prop
          ( pair (Id k l) (is-set-ℕ k l))
          ( λ (f : Fin l ≃ X) →
            is-injective-Fin ((inv-equiv f) ∘e e))
          ( L)))

is-prop-has-finite-cardinality :
  {l1 : Level} {X : UU l1} → is-prop (has-finite-cardinality X)
is-prop-has-finite-cardinality =
  is-prop-is-prop' is-prop-has-finite-cardinality'

has-finite-cardinality-Prop :
  {l1 : Level} (X : UU l1) → UU-Prop l1
has-finite-cardinality-Prop X =
  pair (has-finite-cardinality X) (is-prop-has-finite-cardinality)

is-finite-has-finite-cardinality :
  {l : Level} {X : UU l} → has-finite-cardinality X → is-finite X
is-finite-has-finite-cardinality {l} {X} (pair k K) =
  apply-universal-property-trunc-Prop K
    ( is-finite-Prop X)
    ( is-finite-count ∘ (pair k))

has-finite-cardinality-count :
  {l1  : Level} {X : UU l1} → count X → has-finite-cardinality X
has-finite-cardinality-count e =
  pair (number-of-elements-count e) (unit-trunc-Prop (equiv-count e))

has-finite-cardinality-is-finite :
  {l1 : Level} {X : UU l1} → is-finite X → has-finite-cardinality X
has-finite-cardinality-is-finite =
  map-universal-property-trunc-Prop
    ( has-finite-cardinality-Prop _)
    ( has-finite-cardinality-count)

number-of-elements-is-finite :
  {l1 : Level} {X : UU l1} → is-finite X → ℕ
number-of-elements-is-finite =
  number-of-elements-has-finite-cardinality ∘ has-finite-cardinality-is-finite

mere-equiv-is-finite :
  {l1 : Level} {X : UU l1} (f : is-finite X) →
  mere-equiv (Fin (number-of-elements-is-finite f)) X
mere-equiv-is-finite f =
  mere-equiv-has-finite-cardinality (has-finite-cardinality-is-finite f)

compute-number-of-elements-is-finite :
  {l1 : Level} {X : UU l1} (e : count X) (f : is-finite X) →
  Id (number-of-elements-count e) (number-of-elements-is-finite f)
compute-number-of-elements-is-finite e f =
  ind-trunc-Prop
    ( λ g →
      pair
        ( Id (number-of-elements-count e) (number-of-elements-is-finite g))
        ( is-set-ℕ
          ( number-of-elements-count e)
          ( number-of-elements-is-finite g)))
    ( λ g →
      ( is-injective-Fin ((inv-equiv (equiv-count g)) ∘e (equiv-count e))) ∙
      ( ap pr1
        ( eq-is-prop is-prop-has-finite-cardinality
          ( has-finite-cardinality-count g)
          ( has-finite-cardinality-is-finite (unit-trunc-Prop g)))))
    ( f)

{- Closure properties of finite sets -}

is-finite-empty : is-finite empty
is-finite-empty = is-finite-count count-empty

has-finite-cardinality-empty : has-finite-cardinality empty
has-finite-cardinality-empty = pair zero-ℕ (unit-trunc-Prop equiv-id)

is-finite-is-empty :
  {l1 : Level} {X : UU l1} → is-empty X → is-finite X
is-finite-is-empty H = is-finite-count (count-is-empty H)

has-finite-cardinality-is-empty :
  {l1 : Level} {X : UU l1} → is-empty X → has-finite-cardinality X
has-finite-cardinality-is-empty f =
  pair zero-ℕ (unit-trunc-Prop (equiv-count (count-is-empty f)))

is-empty-is-zero-number-of-elements-is-finite :
  {l1 : Level} {X : UU l1} (f : is-finite X) →
  is-zero-ℕ (number-of-elements-is-finite f) → is-empty X
is-empty-is-zero-number-of-elements-is-finite {l1} {X} f p =
  apply-universal-property-trunc-Prop f
    ( is-empty-Prop X)
    ( λ e →
      is-empty-is-zero-number-of-elements-count e
        ( compute-number-of-elements-is-finite e f ∙ p))

is-finite-unit : is-finite unit
is-finite-unit = is-finite-count count-unit

is-finite-is-contr :
  {l1 : Level} {X : UU l1} → is-contr X → is-finite X
is-finite-is-contr H = is-finite-count (count-is-contr H) 

is-finite-Fin : {k : ℕ} → is-finite (Fin k)
is-finite-Fin {k} = is-finite-count (count-Fin k)

{- Finiteness and coproducts -}

is-finite-coprod :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} →
  is-finite X → is-finite Y → is-finite (coprod X Y)
is-finite-coprod {X = X} {Y} is-finite-X is-finite-Y =
  apply-universal-property-trunc-Prop is-finite-X
    ( is-finite-Prop (coprod X Y))
    ( λ (e : count X) →
      map-universal-property-trunc-Prop
        ( is-finite-Prop (coprod X Y))
        ( is-finite-count ∘ (count-coprod e))
        ( is-finite-Y))

is-finite-left-summand :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} → is-finite (coprod X Y) → is-finite X
is-finite-left-summand =
  functor-trunc-Prop count-left-summand

is-finite-right-summand :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} → is-finite (coprod X Y) → is-finite Y
is-finite-right-summand =
  functor-trunc-Prop count-right-summand

{- Finiteness and products -}

is-finite-prod :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} →
  is-finite X → is-finite Y → is-finite (X × Y)
is-finite-prod {X = X} {Y} is-finite-X is-finite-Y =
  apply-universal-property-trunc-Prop is-finite-X
    ( is-finite-Prop (X × Y))
    ( λ (e : count X) →
      map-universal-property-trunc-Prop
        ( is-finite-Prop (X × Y))
        ( is-finite-count ∘ (count-prod e))
        ( is-finite-Y))

is-finite-left-factor :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} →
  is-finite (X × Y) → Y → is-finite X
is-finite-left-factor f y =
  functor-trunc-Prop (λ e → count-left-factor e y) f

is-finite-right-factor :
  {l1 l2 : Level} {X : UU l1} {Y : UU l2} →
  is-finite (X × Y) → X → is-finite Y
is-finite-right-factor f x =
  functor-trunc-Prop (λ e → count-right-factor e x) f

{- Finite choice -}

finite-choice-Fin :
  {l1 : Level} {k : ℕ} {Y : Fin k → UU l1} →
  ((x : Fin k) → type-trunc-Prop (Y x)) → type-trunc-Prop ((x : Fin k) → Y x)
finite-choice-Fin {l1} {zero-ℕ} {Y} H = unit-trunc-Prop ind-empty
finite-choice-Fin {l1} {succ-ℕ k} {Y} H =
  map-inv-equiv-trunc-Prop
    ( equiv-dependent-universal-property-coprod Y)
    ( map-inv-distributive-trunc-prod-Prop
      ( pair
        ( finite-choice-Fin (λ x → H (inl x)))
        ( map-inv-equiv-trunc-Prop
          ( equiv-ev-star (Y ∘ inr))
          ( H (inr star)))))

finite-choice-count :
  {l1 l2 : Level} {X : UU l1} {Y : X → UU l2} → count X →
  ((x : X) → type-trunc-Prop (Y x)) → type-trunc-Prop ((x : X) → Y x)
finite-choice-count {l1} {l2} {X} {Y} (pair k e) H =
  map-inv-equiv-trunc-Prop
    ( equiv-precomp-Π e Y)
    ( finite-choice-Fin (λ x → H (map-equiv e x)))

finite-choice :
  {l1 l2 : Level} {X : UU l1} {Y : X → UU l2} → is-finite X →
  ((x : X) → type-trunc-Prop (Y x)) → type-trunc-Prop ((x : X) → Y x)
finite-choice {l1} {l2} {X} {Y} is-finite-X H =
  apply-universal-property-trunc-Prop is-finite-X
    ( trunc-Prop ((x : X) → Y x))
    ( λ e → finite-choice-count e H)

{- Finiteness and Σ-types -}

is-finite-Σ :
  {l1 l2 : Level} {X : UU l1} {Y : X → UU l2} →
  is-finite X → ((x : X) → is-finite (Y x)) → is-finite (Σ X Y)
is-finite-Σ {X = X} {Y} is-finite-X is-finite-Y =
  apply-universal-property-trunc-Prop is-finite-X
    ( is-finite-Prop (Σ X Y))
    ( λ (e : count X) →
      map-universal-property-trunc-Prop
        ( is-finite-Prop (Σ X Y))
        ( is-finite-count ∘ (count-Σ e))
        ( finite-choice is-finite-X is-finite-Y))

is-finite-fiber-is-finite-Σ :
  {l1 l2 : Level} {X : UU l1} {Y : X → UU l2} →
  is-finite X → is-finite (Σ X Y) → (x : X) → is-finite (Y x)
is-finite-fiber-is-finite-Σ {l1} {l2} {X} {Y} f g x =
  apply-universal-property-trunc-Prop f
    ( is-finite-Prop (Y x))
    ( λ e → functor-trunc-Prop (λ h → count-fiber-count-Σ e h x) g)

is-prop-is-inhabited :
  {l1 : Level} {X : UU l1} → (X → is-prop X) → is-prop X
is-prop-is-inhabited f x y = f x x y

is-prop-has-decidable-equality :
  {l1 : Level} {X : UU l1} → is-prop (has-decidable-equality X)
is-prop-has-decidable-equality {l1} {X} =
  is-prop-is-inhabited
    ( λ d →
      is-prop-Π
      ( λ x →
        is-prop-Π
        ( λ y →
          is-prop-coprod
          ( intro-dn)
          ( is-set-has-decidable-equality d x y)
          ( is-prop-neg))))

has-decidable-equality-is-finite :
  {l1 : Level} {X : UU l1} → is-finite X → has-decidable-equality X
has-decidable-equality-is-finite {l1} {X} is-finite-X =
  apply-universal-property-trunc-Prop is-finite-X
    ( pair (has-decidable-equality X) is-prop-has-decidable-equality)
    ( λ e →
      has-decidable-equality-equiv' (equiv-count e) has-decidable-equality-Fin)

is-finite-Eq-has-decidable-equality :
  {l1 : Level} {X : UU l1} (d : has-decidable-equality X) →
  {x y : X} → is-finite (Eq-has-decidable-equality d x y)
is-finite-Eq-has-decidable-equality d =
  is-finite-count (count-Eq-has-decidable-equality d)

is-finite-eq :
  {l1 : Level} {X : UU l1} →
  has-decidable-equality X → {x y : X} → is-finite (Id x y)
is-finite-eq d {x} {y} =
  is-finite-equiv
    ( equiv-prop
      ( is-prop-Eq-has-decidable-equality d)
      ( is-set-has-decidable-equality d x y)
      ( eq-Eq-has-decidable-equality d)
      ( Eq-has-decidable-equality-eq d))
    ( is-finite-Eq-has-decidable-equality d)

is-finite-fib-map-section :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} (b : (x : A) → B x) →
  is-finite (Σ A B) → ((x : A) → is-finite (B x)) →
  (t : Σ A B) → is-finite (fib (map-section b) t)
is-finite-fib-map-section {l1} {l2} {A} {B} b f g (pair y z) =
  is-finite-equiv'
    ( ( ( left-unit-law-Σ-is-contr
            ( is-contr-total-path' y)
            ( pair y refl)) ∘e
        ( inv-assoc-Σ A
          ( λ x → Id x y)
          ( λ t → Id (tr B (pr2 t) (b (pr1 t))) z))) ∘e
      ( equiv-tot (λ x → equiv-pair-eq-Σ (pair x (b x)) (pair y z))))
    ( is-finite-eq (has-decidable-equality-is-finite (g y)))

is-empty-type-trunc-Prop :
  {l1 : Level} {X : UU l1} → is-empty X → is-empty (type-trunc-Prop X)
is-empty-type-trunc-Prop f =
  map-universal-property-trunc-Prop empty-Prop f

is-empty-type-trunc-Prop' :
  {l1 : Level} {X : UU l1} → is-empty (type-trunc-Prop X) → is-empty X
is-empty-type-trunc-Prop' f = f ∘ unit-trunc-Prop

elim-trunc-decidable-fam-Fin :
  {l1 : Level} {k : ℕ} {B : Fin k → UU l1} →
  ((x : Fin k) → is-decidable (B x)) →
  type-trunc-Prop (Σ (Fin k) B) → Σ (Fin k) B
elim-trunc-decidable-fam-Fin {l1} {zero-ℕ} {B} d y =
  ex-falso (is-empty-type-trunc-Prop pr1 y)
elim-trunc-decidable-fam-Fin {l1} {succ-ℕ k} {B} d y
  with d (inr star)
... | inl x = pair (inr star) x
... | inr f =
  map-Σ-map-base inl B
    ( elim-trunc-decidable-fam-Fin {l1} {k} {B ∘ inl}
      ( λ x → d (inl x))
      ( map-equiv-trunc-Prop
        ( ( ( right-unit-law-coprod-is-empty
              ( Σ (Fin k) (B ∘ inl))
              ( B (inr star)) f) ∘e
            ( equiv-coprod equiv-id (left-unit-law-Σ (B ∘ inr)))) ∘e
          ( right-distributive-Σ-coprod (Fin k) unit B))
        ( y)))

is-finite-base-is-finite-Σ-section :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} (b : (x : A) → B x) →
  is-finite (Σ A B) → ((x : A) → is-finite (B x)) → is-finite A
is-finite-base-is-finite-Σ-section {l1} {l2} {A} {B} b f g =
  apply-universal-property-trunc-Prop f
    ( is-finite-Prop A)
    ( λ e →
      is-finite-count
        ( count-equiv
          ( ( equiv-total-fib-map-section b) ∘e
            ( equiv-tot
              ( λ t →
                ( equiv-tot (λ x → equiv-eq-pair-Σ (map-section b x) t)) ∘e
                ( ( assoc-Σ A
                    ( λ (x : A) → Id x (pr1 t))
                    ( λ s → Id (tr B (pr2 s) (b (pr1 s))) (pr2 t))) ∘e
                  ( inv-left-unit-law-Σ-is-contr
                    ( is-contr-total-path' (pr1 t))
                    ( pair (pr1 t) refl))))))
          ( count-Σ e
            ( λ t → count-eq (has-decidable-equality-is-finite (g (pr1 t)))))))

is-finite-base-is-finite-Σ-mere-section :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
  type-trunc-Prop ((x : A) → B x) →
  is-finite (Σ A B) → ((x : A) → is-finite (B x)) → is-finite A
is-finite-base-is-finite-Σ-mere-section {l1} {l2} {A} {B} H f g =
  apply-universal-property-trunc-Prop H
    ( is-finite-Prop A)
    ( λ b → is-finite-base-is-finite-Σ-section b f g)

is-prop-leq-Fin :
  {k : ℕ} (x y : Fin k) → is-prop (leq-Fin x y)
is-prop-leq-Fin {succ-ℕ k} (inl x) (inl y) = is-prop-leq-Fin x y
is-prop-leq-Fin {succ-ℕ k} (inl x) (inr star) = is-prop-unit
is-prop-leq-Fin {succ-ℕ k} (inr star) (inl y) = is-prop-empty
is-prop-leq-Fin {succ-ℕ k} (inr star) (inr star) = is-prop-unit

is-prop-is-lower-bound-Fin :
  {l : Level} {k : ℕ} {P : Fin k → UU l} (x : Fin k) →
  is-prop (is-lower-bound-Fin P x)
is-prop-is-lower-bound-Fin x =
  is-prop-Π (λ y → is-prop-function-type (is-prop-leq-Fin x y))

is-prop-minimal-element-subtype-Fin' :
  {l : Level} {k : ℕ} (P : Fin k → UU l) →
  ((x : Fin k) → is-prop (P x)) → is-prop' (minimal-element-Fin P)
is-prop-minimal-element-subtype-Fin' P H
  (pair x (pair p l)) (pair y (pair q m)) =
  eq-subtype
    ( λ t → is-prop-prod (H t) (is-prop-is-lower-bound-Fin t))
    ( antisymmetric-leq-Fin (l y q) (m x p))

is-prop-minimal-element-subtype-Fin :
  {l : Level} {k : ℕ} (P : Fin k → UU l) →
  ((x : Fin k) → is-prop (P x)) → is-prop (minimal-element-Fin P)
is-prop-minimal-element-subtype-Fin P H =
  is-prop-is-prop' (is-prop-minimal-element-subtype-Fin' P H)

is-prop-leq-count :
  {l : Level} {A : UU l} (e : count A) {x y : A} → is-prop (leq-count e x y)
is-prop-leq-count e {x} {y} =
  is-prop-leq-Fin (map-inv-equiv-count e x) (map-inv-equiv-count e y)

is-prop-is-lower-bound-count :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} (e : count A) →
  (x : A) → is-prop (is-lower-bound-count e B x)
is-prop-is-lower-bound-count e x =
  is-prop-Π ( λ x → is-prop-function-type (is-prop-leq-count e))

equiv-is-lower-bound-count :
  {l1 l2 : Level} {A : UU l1} (e : count A) {B : A → UU l2} →
  (x : Fin (number-of-elements-count e)) →
  is-lower-bound-Fin (B ∘ map-equiv-count e) x ≃
  is-lower-bound-count e B (map-equiv-count e x)
equiv-is-lower-bound-count e {B} x =
  equiv-prop
    ( is-prop-is-lower-bound-Fin x)
    ( is-prop-is-lower-bound-count e (map-equiv-count e x))
    ( λ H y l →
      transpose-leq-equiv-count e
        ( H ( map-inv-equiv-count e y)
            ( tr B (inv (issec-map-inv-equiv (equiv-count e) y)) l)))
    ( λ H y l →
      reflects-leq-equiv-count e (H (map-equiv-count e y) l))

is-prop-first-element-subtype-count :
  {l1 l2 : Level} {A : UU l1} (e : count A) {P : A → UU l2} →
  ((x : A) → is-prop (P x)) → is-prop (first-element-count e P)
is-prop-first-element-subtype-count e {P} H =
  is-prop-equiv'
    ( minimal-element-Fin (P ∘ map-equiv-count e))
    ( equiv-Σ
      ( λ x → P x × is-lower-bound-count e P x)
      ( equiv-count e)
      ( λ x → equiv-prod equiv-id (equiv-is-lower-bound-count e x)))
    ( is-prop-minimal-element-subtype-Fin
      ( P ∘ map-equiv-count e)
      ( λ y → H (map-equiv-count e y)))

first-element-subtype-count-Prop :
  {l1 l2 : Level} {A : UU l1} (e : count A) {P : A → UU l2} →
  ((x : A) → is-prop (P x)) → UU-Prop (l1 ⊔ l2)
first-element-subtype-count-Prop e {P} H =
  pair
    ( first-element-count e P)
    ( is-prop-first-element-subtype-count e H)

element-inhabited-decidable-subtype-Fin :
  {l : Level} {k : ℕ} {P : Fin k → UU l} →
  ((x : Fin k) → is-decidable (P x)) → ((x : Fin k) → is-prop (P x)) →
  type-trunc-Prop (Σ (Fin k) P) → Σ (Fin k) P
element-inhabited-decidable-subtype-Fin {l} {k} {P} d H t =
  tot
    ( λ x → pr1)
    ( apply-universal-property-trunc-Prop t
      ( pair
        ( minimal-element-Fin P)
        ( is-prop-minimal-element-subtype-Fin P H))
      ( minimal-element-decidable-subtype-Fin d))

choice-subtype-count :
  {l1 l2 : Level} {A : UU l1} (e : count A) {P : A → UU l2} →
  ((x : A) → is-decidable (P x)) → ((x : A) → is-prop (P x)) →
  type-trunc-Prop (Σ A P) → Σ A P
choice-subtype-count e d H t =
  tot
    ( λ x → pr1)
    ( apply-universal-property-trunc-Prop t
      ( first-element-subtype-count-Prop e H)
      ( first-element-is-decidable-subtype-count e d H))

is-inhabited-or-empty : {l1 : Level} → UU l1 → UU l1
is-inhabited-or-empty A = coprod (type-trunc-Prop A) (is-empty A)

is-prop-is-inhabited-or-empty :
  {l1 : Level} (A : UU l1) → is-prop (is-inhabited-or-empty A)
is-prop-is-inhabited-or-empty A =
  is-prop-coprod
    ( λ t → apply-universal-property-trunc-Prop t empty-Prop)
    ( is-prop-type-trunc-Prop)
    ( is-prop-neg)

is-inhabited-or-empty-Prop : {l1 : Level} → UU l1 → UU-Prop l1
is-inhabited-or-empty-Prop A =
  pair (is-inhabited-or-empty A) (is-prop-is-inhabited-or-empty A)

is-inhabited-or-empty-count :
  {l1 : Level} {A : UU l1} → count A → is-inhabited-or-empty A
is-inhabited-or-empty-count (pair zero-ℕ e) =
  inr (is-empty-is-zero-number-of-elements-count (pair zero-ℕ e) refl)
is-inhabited-or-empty-count (pair (succ-ℕ k) e) =
  inl (unit-trunc-Prop (map-equiv e zero-Fin))

is-inhabited-or-empty-is-finite :
  {l1 : Level} {A : UU l1} → is-finite A → is-inhabited-or-empty A
is-inhabited-or-empty-is-finite {l1} {A} f =
  apply-universal-property-trunc-Prop f
    ( is-inhabited-or-empty-Prop A)
    ( is-inhabited-or-empty-count)

choice-emb-count :
  {l1 l2 : Level} {A : UU l1} (e : count A) {B : UU l2} (f : B ↪ A) →
  ((x : A) → is-decidable (fib (map-emb f) x)) → type-trunc-Prop B → B
choice-emb-count e f d t =
  map-equiv-total-fib
    ( map-emb f)
    ( choice-subtype-count e d
      ( is-prop-map-emb f)
      ( functor-trunc-Prop
        ( map-inv-equiv-total-fib (map-emb f))
        ( t)))

{- We show that if A is a proposition, then so is is-decidable A. -}

is-prop-is-decidable :
  {l : Level} {A : UU l} → is-prop A → is-prop (is-decidable A)
is-prop-is-decidable is-prop-A =
  is-prop-coprod intro-dn is-prop-A is-prop-neg

is-decidable-Prop :
  {l : Level} → UU-Prop l → UU-Prop l
is-decidable-Prop P =
  pair (is-decidable (type-Prop P)) (is-prop-is-decidable (is-prop-type-Prop P))

count-total-subtype-is-finite-total-subtype :
  {l1 l2 : Level} {A : UU l1} (e : count A) (P : A → UU-Prop l2) →
  is-finite (Σ A (λ x → type-Prop (P x))) → count (Σ A (λ x → type-Prop (P x)))
count-total-subtype-is-finite-total-subtype {l1} {l2} {A} e P f =
  count-decidable-subtype P d e
  where
  d : (x : A) → is-decidable (type-Prop (P x))
  d x =
    apply-universal-property-trunc-Prop f
      ( is-decidable-Prop (P x))
      ( λ g → is-decidable-count-Σ e g x)

count-domain-emb-is-finite-domain-emb :
  {l1 l2 : Level} {A : UU l1} (e : count A) {B : UU l2} (f : B ↪ A) →
  is-finite B → count B
count-domain-emb-is-finite-domain-emb e f H =
  count-equiv
    ( equiv-total-fib (map-emb f))
    ( count-total-subtype-is-finite-total-subtype e
      ( λ x → pair (fib (map-emb f) x) (is-prop-map-emb f x))
      ( is-finite-equiv'
        ( equiv-total-fib (map-emb f))
        ( H)))

fiber-inclusion :
  {l1 l2 : Level} {A : UU l1} (B : A → UU l2) (x : A) → B x → Σ A B
fiber-inclusion B x = pair x

map-transpose-total-span :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : A → B → UU l3} →
  Σ A (Σ B ∘ C) → Σ B (λ y → Σ A (λ x → C x y))
map-transpose-total-span (pair x (pair y z)) = pair y (pair x z)

map-inv-transpose-total-span :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : A → B → UU l3} →
  Σ B (λ y → Σ A (λ x → C x y)) → Σ A (Σ B ∘ C)
map-inv-transpose-total-span (pair y (pair x z)) = pair x (pair y z)

issec-map-inv-transpose-total-span :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : A → B → UU l3} →
  ( ( map-transpose-total-span {A = A} {B} {C}) ∘
    ( map-inv-transpose-total-span {A = A} {B} {C})) ~ id
issec-map-inv-transpose-total-span (pair y (pair x z)) = refl

isretr-map-inv-transpose-total-span :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : A → B → UU l3} →
  ( ( map-inv-transpose-total-span {A = A} {B} {C}) ∘
    ( map-transpose-total-span {A = A} {B} {C})) ~ id
isretr-map-inv-transpose-total-span (pair x (pair y z)) = refl

is-equiv-map-transpose-total-span :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : A → B → UU l3} →
  is-equiv (map-transpose-total-span {A = A} {B} {C})
is-equiv-map-transpose-total-span =
  is-equiv-has-inverse
    map-inv-transpose-total-span
    issec-map-inv-transpose-total-span
    isretr-map-inv-transpose-total-span

transpose-total-span :
  {l1 l2 l3 : Level} {A : UU l1} {B : UU l2} {C : A → B → UU l3} →
  Σ A (Σ B ∘ C) ≃ Σ B (λ y → Σ A (λ x → C x y))
transpose-total-span =
  pair map-transpose-total-span is-equiv-map-transpose-total-span

is-emb-fiber-inclusion :
  {l1 l2 : Level} {A : UU l1} (B : A → UU l2) →
  is-set A → (x : A) → is-emb (fiber-inclusion B x)
is-emb-fiber-inclusion B H x =
  is-emb-is-prop-map
    ( λ z →
      is-prop-equiv
        ( Id x (pr1 z))
        ( ( ( right-unit-law-Σ-is-contr
                ( λ p →
                  is-contr-map-is-equiv (is-equiv-tr B p) (pr2 z))) ∘e
            ( transpose-total-span)) ∘e
          ( equiv-tot (λ y → equiv-pair-eq-Σ (pair x y) z)))
        ( H x (pr1 z)))

emb-fiber-inclusion :
  {l1 l2 : Level} {A : UU l1} (B : A → UU l2) → is-set A → (x : A) → B x ↪ Σ A B
emb-fiber-inclusion B H x =
  pair (fiber-inclusion B x) (is-emb-fiber-inclusion B H x)

choice : {l : Level} → UU l → UU l
choice X = type-trunc-Prop X → X

choice-count :
  {l : Level} {A : UU l} → count A → choice A
choice-count (pair zero-ℕ e) t =
  ex-falso
    ( apply-universal-property-trunc-Prop t empty-Prop
      ( is-empty-is-zero-number-of-elements-count (pair zero-ℕ e) refl))
choice-count (pair (succ-ℕ k) e) t = map-equiv e zero-Fin

choice-count-Σ-is-finite-fiber :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
  is-set A → count (Σ A B) → ((x : A) → is-finite (B x)) →
  ((x : A) → type-trunc-Prop (B x)) → (x : A) → B x
choice-count-Σ-is-finite-fiber {l1} {l2} {A} {B} K e g H x =
   choice-count
     ( count-domain-emb-is-finite-domain-emb e
       ( emb-fiber-inclusion B K x)
       ( g x))
     ( H x)

choice-is-finite-Σ-is-finite-fiber :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
  is-set A → is-finite (Σ A B) → ((x : A) → is-finite (B x)) →
  ((x : A) → type-trunc-Prop (B x)) → type-trunc-Prop ((x : A) → B x)
choice-is-finite-Σ-is-finite-fiber {l1} {l2} {A} {B} K f g H =
  apply-universal-property-trunc-Prop f
    ( trunc-Prop ((x : A) → B x))
    ( λ e → unit-trunc-Prop (choice-count-Σ-is-finite-fiber K e g H))

is-finite-base-is-finite-Σ-merely-inhabited :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} →
  is-set A → (b : (x : A) → type-trunc-Prop (B x)) →
  is-finite (Σ A B) → ((x : A) → is-finite (B x)) → is-finite A
is-finite-base-is-finite-Σ-merely-inhabited {l1} {l2} {A} {B} K b f g =
  is-finite-base-is-finite-Σ-mere-section
    ( choice-is-finite-Σ-is-finite-fiber K f g b)
    ( f)
    ( g)

count-type-trunc-Prop :
  {l1 : Level} {A : UU l1} → count A → count (type-trunc-Prop A)
count-type-trunc-Prop (pair zero-ℕ e) =
  count-is-empty
    ( is-empty-type-trunc-Prop
      ( is-empty-is-zero-number-of-elements-count (pair zero-ℕ e) refl))
count-type-trunc-Prop (pair (succ-ℕ k) e) =
  count-is-contr
    ( is-proof-irrelevant-is-prop
      ( is-prop-type-trunc-Prop)
      ( unit-trunc-Prop (map-equiv e zero-Fin)))

is-finite-type-trunc-Prop :
  {l1 : Level} {A : UU l1} → is-finite A → is-finite (type-trunc-Prop A)
is-finite-type-trunc-Prop = functor-trunc-Prop count-type-trunc-Prop

complement :
  {l1 l2 : Level} {A : UU l1} (B : A → UU l2) → UU (l1 ⊔ l2)
complement {l1} {l2} {A} B = Σ A (is-empty ∘ B)

is-finite-base-is-finite-complement :
  {l1 l2 : Level} {A : UU l1} {B : A → UU l2} → is-set A →
  is-finite (Σ A B) → (g : (x : A) → is-finite (B x)) →
  is-finite (complement B) → is-finite A
is-finite-base-is-finite-complement {l1} {l2} {A} {B} K f g h =
  is-finite-equiv
    ( ( right-unit-law-Σ-is-contr
        ( λ x →
          is-proof-irrelevant-is-prop
            ( is-prop-is-inhabited-or-empty (B x))
            ( is-inhabited-or-empty-is-finite (g x)))) ∘e
      ( inv-equiv
        ( left-distributive-Σ-coprod A
          ( λ x → type-trunc-Prop (B x))
          ( λ x → is-empty (B x)))))
    ( is-finite-coprod
      ( is-finite-base-is-finite-Σ-merely-inhabited
        ( is-set-subtype (λ x → is-prop-type-trunc-Prop) K)
        ( λ t → pr2 t)
        ( is-finite-equiv
          ( equiv-double-structure B (λ x → type-trunc-Prop (B x)))
          ( is-finite-Σ
            ( f)
            ( λ x → is-finite-type-trunc-Prop (g (pr1 x)))))
        ( λ x → g (pr1 x)))
      ( h))  

# Decision Matrix

Every piece gets exactly one verdict. Go through the library one piece at a time.

## The deciding questions

1. **Who authors it?** shadcn already, or JTL?
2. **Does it carry real logic?** State and behavior, or just markup and arrangement?
3. **How many apps use it?** Many, or exactly one?
4. **Is its layout fixed or varying?** One blessed arrangement, or different each use?
5. **Would using shadcn's raw version lose functionality JTL depends on?** This is
   the deciding question whenever shadcn already ships an equivalent.

**Coverage is not the verdict.** That shadcn ships an equivalent only means shadcn
has the parts; it does not mean JTL should stop authoring the piece. On question 5:

- **No** → consume the shadcn atom, or document a Recipe.
- **Yes** → JTL keeps authoring it: a Component if it is one small unit, otherwise
  a Block.

A large file count is a hint to ask question 5, not an answer on its own.

## The verdicts

Take the first verdict that fits.

1. **Remove (use shadcn atom).** A shadcn atom already covers it and JTL adds no
   logic. JTL stops shipping its own version and consumes shadcn's; the look holds,
   only the source moves. API: shadcn's own. This is the bulk of the library.
2. **Recipe.** A pure arrangement of existing atoms, varying per use. shadcn
   supplies the parts but no packaged whole, so freezing it as one unit would be
   wrong. Document the pattern instead of shipping code. API: composition,
   assembled in app code.
3. **Component.** JTL-only and small enough for one file (Tag, Logo, styled Icon).
   API: variant props, the shape of a shadcn atom.
4. **Block.** Real logic, state, or accessibility wiring, reused across apps. More
   than arrangement: there is behavior to own and an opinion worth enforcing.
   Package it as a multi-file unit on shadcn atoms. Check a third-party registry
   first; pull instead of build if one fits well. API: composition while the
   design is settling, a property API once it matures.
5. **Snowflake.** Heavy, and used by exactly one app. Keeping it central costs more
   than it returns, so it moves out of the library into the single app that uses
   it (for example an HTML editor, the heaviest data table). API: no longer JTL's
   concern once it leaves the library.
6. **Enhanced Block (keep the property API).** Same name as a shadcn component, but
   JTL ships a feature superset apps already depend on (for example a combo-box
   with grouped results, async loading, multi-select). JTL keeps authoring it as a
   Block, shadowing the shadcn name under the `@jtl` namespace. This is the one
   Block that does not start from composition: its design is proven and its
   existing property API is the contract apps rely on.

Only verdicts 1 and 5 move JTL's code (back to shadcn, or out to an app). The
others keep JTL authoring the thing in a new form. Nothing deletes UI from an app.

## Boundary moves

A verdict is not permanent.

- A **Recipe promotes to a Block** once a second app needs the same arrangement and
  it stabilizes.
- A **Block demotes to a Recipe** when it turns out to be pure arrangement and keeps
  needing per-app edits.
- The API shape moves the same way: a Component or Block starts as composition and
  graduates to a property API once its design proves stable.

Record today's verdict, not a frozen one.

## Related

- [architecture.md](architecture.md) — definitions of each form and the API shapes.
- [authoring/recipe.md](authoring/recipe.md) — when the verdict is Recipe.
- [authoring/block.md](authoring/block.md) — when the verdict is Block.

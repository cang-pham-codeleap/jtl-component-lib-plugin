Overview
This document is the detailed guide for Step 6 of the Component Library's shadcn migration, "Rebuild JTL-UI components with shadcn primitives and publish through the shadcn registry". The parent roadmap names that step and lists the components it covers; this document supplies the vocabulary and the decision rule for carrying it out, then applies that rule to every surviving component.

It answers one question, component by component: once JTL retires its npm library, what form does each piece take, and who owns it?

The Goal

When the existing component library is deprecated, our 1st Party Applications (HUB, Partner Portal, WMS, ERP) keep their current look, or alter it only slightly. What changes is how they consume a component: Composition and a shadcn add CLI command in place of an npm import. The expectation is that this migration would leave little to no visual discrepancy.

AI Advantages

Hosting the UI in the registry is what unlocks the AI benefit of moving to shadcn. An agent reads the registry directly and understands each component, its props, and how it is composed.

The Vocabulary

JTL rebuilds its UI on shadcn atoms and ships the result through a shadcn registry. "A JTL component" is not one kind of thing: it ships as a Component, a Block, or a Recipe. That choice decides what JTL maintains, how a consumer installs it, and how much an AI agent has to do.

The document moves in four steps:

The three JTL terms. Component, Block, and Recipe are defined on top of shadcn registry types. Includes the API shape each term carries.

The guideline & verdict. How to decide which form a component takes, then that rule applies to every surviving JTL component.

Consuming applications. What changes and what stays the same for 1st Party Application (1

The registry type reference. The full set of shadcn registry types, for completeness.

Overview
The Architecture
The layering
Atom
Component
Block
Recipe
The API Shape: Property vs Composition
Property API
Composition API
Hybrid API
The default and the Graduation Path
Consuming applications
The decision matrix
The boundary moves
Per-component verdict
What the inventory tallies to
Full breakdown
External Library (UI-React)
Internal Library (Internal-React)
Appendix: shadcn registry type reference
Related
The Architecture
The JTL Registry (registry.jtl-software.com) is an extension of the Shadcn base registry (ui.shadcn.com).

Relationship of the two:

As install sources, peers. A consuming app's components.json lists both registries, and shadcn add pulls from either: base atoms straight from shadcn, JTL items from the JTL Registry.

As construction, layered. Every JTL item builds on shadcn's atom layer: a Component wraps one atom, a Block declares its atoms in registryDependencies, a Recipe composes already-installed items. shadcn ships the full atomic stack; JTL ships only what shadcn lacks.

Within this structure, JTL ships four kinds of things through the registry: Atom, Component, Block, and Recipe.

The layering
The terms follow Atomic Design.

Atom is the base layer, Component a molecule, Block an organism. The layer a piece sits at determines what JTL builds it from, not how it looks.

Layer

Atomic Design

What it is

API Strategy

Built on

shadcn type

Behavior

below the atom

headless, unstyled interaction: focus, dismiss, keyboard nav

-

the browser

none (Radix, or a hook)

Atom

atom

A behavior plus JTL tokens and Tailwind.

A JTL-authored unit when shadcn ships none.

Property

Radix, or raw DOM when Radix has none

By default, all of the base shadcn component is shipped from this type

registry:ui

Examples

Component

molecule

A thin wrapper on a single atom.

Hybrid

Mix of both strategies, calibrated by the vision for where the component sits on the spectrum.

one or two atom(s)

registry:component

Block

organism

a composed feature: several atoms and Components wired with logic and state

Property

Opinionated by design.

Customization comes through composition (slots, children, render functions), not props. Prop explosion here signals the wrong abstraction layer.

the layers below it

registry:block

Recipe sits outside both: the same composition as a Block, but assembled into app code per use rather than shipped as an owned unit.

Each term is defined in full below.

Atom
An Atom is JTL's own base unit: one registry:ui file, a raw DOM element plus JTL tokens, shipped only where shadcn has no equivalent.

This is the smallest shippable code unit in the JTL registry, the atom layer of Atomic Design.

shadcn type: registry:ui (lands in components/ui/).

Rare by design:

For our Design System, the base atoms come straight from Shadcn, themed by JTL tokens.

JTL authors an Atom only when it has nothing to consume: jtl-logo, tag, styled-icon.

API: variant props, the same shape as a shadcn atom.

Our current roughly 30 base atoms (Button, Input, Dialog) will not be "JTL's" after the migration, they will come straight from shadcn and are themed by tokens.

Component
A Component is a single, self-contained UI element: one file, one purpose.

This is the smallest shippable code unit in the JTL registry. In Atomic Design terms, it is a molecule.

The smallest level of any Component Library is the Atom (ie: Button, Labels,...), as we'll be using most of the atoms from Shadcn. Therefore, it'd be an edge case if the JTL Registry ships its own atom.

shadcn type:

registry:ui when it is a base atom other pieces build on (lands in components/ui/).

registry:component for a standalone small piece (lands in components/).

API:

Preferably Compositional

Built from:

One atom, shadcn's or a JTL Atom.

When neither fits, built directly on the DOM, or another library (ie: cmdk)

Block
A Block is a multi-file working unit: a main component plus its sub-parts and hooks, shipped together as code, declaring the shadcn Atoms, or Molecules it depends on.

In Atomic Design terms, it is an organism: several molecules and atoms forming a distinct section of the interface.

shadcn type:registry:block.

Atoms: declared in registryDependencies and installed alongside it by the CLI. Imported from @/components/ui/\* in the consumer's project.

Files: a flat list of a handful of files, not deeply nested sub-folders.

Use for: the surviving JTL composites (@jtl/app-sidebar, @jtl/file-upload, @jtl/stepper). Each is built on shadcn atoms, copied into the app, then owned.

API.

Format:

Property: A Block is an opinionated piece of the interface, so structuring it in the property format follows directly.

Hybrid: We can also keep the property entry point and expose a composition slot only for the part that genuinely varies per app (a custom table cell, a toolbar action).

The props serve the Developer:

The shipped code is owned by the Application Developer.

The opinionated property API exists to make it easy for the Developer to replicate JTL's look and feel: pass props, get the JTL-approved result, no assembly required.

Last resort: when neither props nor a slot fit, the consumer edits the owned copy.

Example Block from Shadcn:

login-03: a login page in two files (the page plus a login-form), composing the card, input, label, and button atoms.

sidebar-07: a collapsible sidebar. Declares registryDependencies: ["sidebar", "breadcrumb", "separator", "collapsible", "dropdown-menu", "avatar"] and ships a handful of flat files (app-sidebar, nav-main, nav-user, team-switcher).

dashboard-01: the heavy end, nine files composing a sidebar, charts, and a data table into one screen.

Recipe
A Recipe is a documented pattern: how to compose already-installed atoms into something, assembled per use.

It can be plain instruction, copy-paste reference code, or both. What makes it a Recipe is that the result lands in app code, adapted each time, and is never maintained as a shared JTL unit.

Term: Recipe is JTL's own vocabulary, taken from established design-system practice. Brad Frost calls it a Recipe: a composition used consistently within a product but not agnostic enough to live in the system. Nathan Curtis calls the same idea a pattern: a component is how something does work, a pattern is how something should work.

No install: there is no registry:recipe type. A Recipe travels by whatever vehicle fits — a plain docs page, a registry:item with a docs field, or a markdown file via registry:file such as AGENTS.md.

Canonical shape: shadcn's own React Hook Form guide. No shadcn add form — just a docs page of copy-paste code wiring useForm to the already-installed field atoms. The developer copies and adapts. Mostly code, zero install.

Use for: things shadcn supplies the atoms for but ships no packaged whole — ComboBox (compose popover plus command), DatePicker (compose input plus calendar plus popover), Form (compose the field atoms per shadcn's guide).

A Recipe and a Block are the same idea at two settings: packaged as an installable unit (Block) or documented as a per-use composition (Recipe). The difference is destination and ownership, not code versus knowledge. A Block buys consistency at a maintenance cost; a Recipe buys flexibility at a consistency cost. JTL's bias is toward a Recipe when the logic is thin.

The API Shape: Property vs Composition
The API of the Component is pivotal in how we build Components for the Component Library. Every item ships with one of three shapes: property, composition, or hybrid.

Property API
One configured entry point driven by props. The consumer passes options and callbacks and never touches the internals.

JTL's ComboBox shows the shape: <ComboBox options onSelect />. The previous iteration of the Component Library is tailored to this shape.

Buys: consistency across apps, and one fix propagates everywhere. Developers use a component without knowing its internals.

Costs: flexibility. Changing a component's design means changing its props, and that change ripples across every app.

Use when: the design is proven and stable, and the opinion is worth enforcing (mature Blocks, Enhanced Blocks).

Composition API
The consumer assembles the component from exposed parts. The opinion lives in the arrangement, not in a closed surface.

shadcn's ComboBox shows the shape: composed from a popover and a command. This is shadcn's native grain.

Buys: flexibility while the design is still moving. A design change is a rearrangement, not a breaking prop change rippling across every app.

Costs: consistency. Every call site can drift, and a fix must be applied per arrangement.

Use when: the design is still settling, or the arrangement varies per use (new Components and Blocks, all Recipes).

Hybrid API
A property API entry point that exposes composition slots for the parts that genuinely vary per app, for example a custom table cell or a toolbar action.

Buys: the consistency of props for the stable core, the flexibility of slots where variation is real.

Costs: a larger surface to design and document; a slot is a commitment like a prop.

Use when: a Block has matured into a property API but one or two parts still differ per app. Prefer a slot over reopening the whole component.

The default and the Graduation Path
This migration removes JTL's Atoms and rebuilds on shadcn's. Therefore, we'll use this Migration to default to composition over property API. It matches shadcn's grain, so Developers and Agents meet one familiar interface.

The property API is not dropped. It is the mature end of the path: once a component's design is proven and stable, it graduates to a property API to lock the consistency in, growing hybrid slots only where per-app variation persists. This works because shadcn's real change is ownership, not API shape: every component is shipped as open code that the Developer owns either way, so a property API is no longer a closed prison, just the ergonomic surface we reach for once a design has earned it.

With the API shape as the guiding rule, the decision matrix applies it: every existing component gets a verdict and the API shape that follows from it.

Consuming applications
The JTL 1st Party Applications — HUB, WMS, ERP, and Partner Portal — are the direct consumers of the component library. This migration changes how they consume components, not what they see.

What changes:

Before

After

npm install @jtl-software/platform-ui-react

pnpm dlx shadcn@latest add @jtl-software/<item>

Import from npm package

Import from owned copy in components/

Prop-driven API (closed, configured)

Composition API (open, owned) for most items

JTL controls the update cycle

App team controls when to re-run shadcn add

What stays the same: visual output. Atoms are themed by JTL tokens; the look holds.

What the app teams own:

Call-site rewrites: replacing npm imports with the installed shadcn code.

Snowflake re-homing: heavy single-use components (data-table, html-editor, code-editor) move into the owning app's codebase.

Registry configuration: each consuming app adds one entry to components.json:

{
"registries": {
"jtl-software": "https://registry.jtl-software.com"
}
}
Migration window. Component Library and the app teams migrate in parallel. The legacy npm package stays available during the transition. An app team is fully off the legacy library once it has replaced all its imports and dropped @jtl-software/platform-ui-react from its dependencies.

The decision matrix
Every component gets exactly one verdict. Go through the library one component at a time and ask:

Who authors it? shadcn already, or JTL?

Does it carry real logic? State and behaviour, or just markup and arrangement?

How many apps use it? Many, or exactly one?

Is its layout fixed or varying? One blessed arrangement, or different on each use?

Would using shadcn's raw version lose functionality JTL depends on? The deciding question whenever shadcn already ships an equivalent.

The answers point to one of the verdicts below, and also fix the API shape (composition or property).

Coverage is not the verdict. That shadcn ships an equivalent only means shadcn has the parts; it does not mean JTL should stop authoring the component. So on that last question:

No → consume the shadcn atom, or document a Recipe.

Yes → JTL keeps authoring it: a Component if it is one small unit, otherwise a Block.

A large file count is a hint to ask that question, not an answer on its own.

Take the first verdict that fits:

A shadcn atom already covers it, and JTL adds no logic → Remove (use shadcn atom). shadcn ships an equivalent that needs only JTL tokens or light markup. JTL stops shipping its own version and consumes shadcn's; the look holds, only the source moves. This is the bulk of the library and the easiest part. API: shadcn's own.

A pure arrangement of existing atoms, varying per use → Recipe. shadcn supplies the parts but no packaged whole, and the composition differs each time, so freezing it as one unit would be wrong. JTL documents the pattern instead of shipping code. API: composition, assembled in app code.

JTL-only, and small enough for one file → Component. A single piece shadcn has no equivalent for, too simple to be a Block: the Tag, the Logo, a styled Icon. API: variant props, the shape of a shadcn atom.

Real logic, state, or accessibility wiring, reused across apps → Block. More than arrangement: there is behavior to own and an opinion worth enforcing across apps. JTL packages it as a multi-file unit on shadcn atoms. This is also the case where shadcn ships only an atom and JTL builds the logic on top, which is why sidebar and pagination are Blocks, not consumed atoms. Check a third-party registry first; pull instead of build if one fits well. If JTL's Block shadows a shadcn component of the same name and only extends it, it is the enhanced case in verdict 6. API: composition while the design is still settling, a property API once it matures, because a Block is the opinionated lane (see API shape above).

Heavy, and used by exactly one app → Snowflake. A one-off that will not be reused elsewhere, so keeping it central costs more than it returns. It moves out of the library into the single app that uses it. This is Brad Frost's Snowflake: a one-off that does not get reused beyond its first use case. Examples: the HTML editor, the heaviest data table. API: no longer JTL's concern once it leaves the library.

Same name as a shadcn component, but JTL ships more → Enhanced Block (keep the property API). shadcn has the component, but JTL's version is a feature superset apps already depend on: the combo-box (grouped results, async loading, multi-select) and command (variants, server-side search, selection config). JTL keeps authoring it as a Block, shadowing the shadcn name under the @jtl namespace (@jtl/combo-box). It is the one Block that does not start from composition: its design is already proven and its existing property API is the contract apps rely on, so it keeps that interface from day one. This is a special case of the Block verdict (4). API: the existing property API, not composition.

Only verdicts 1 and 5 move JTL's code, back to shadcn or out to an app; the others keep JTL authoring the thing in a new form. Nothing here deletes UI from an app.

The boundary moves
A verdict is not permanent.

A Recipe that gets copied often and stabilizes promotes to a Block once a second app needs the same arrangement.

A Block that turns out to be pure arrangement and keeps needing per-app edits demotes to a Recipe. The API shape moves the same way: a Component or Block starts as a composition and graduates to a property API once its design proves stable. So the inventory below records today's verdict, not a frozen one.

Per-component verdict
The decision matrix is applied to every component in jtl-platform-ui-react and jtl-platform-internal-react. Each row gets one verdict, defined above. Nothing is deleted from any app's UI.

What the inventory tallies to
// add table

The full per-component breakdown follows.

Full breakdown
Column legend:

shadcn coverage is context only, not the verdict: atom = a direct shadcn equivalent; drop-in = shadcn shipped one (some in 2025); recipe-only = shadcn supplies the parts but no packaged item; none = shadcn ships nothing.

JTL value-add is what JTL's version adds beyond shadcn, or none when consuming shadcn loses nothing. This is the added-value test and it drives the verdict (see Coverage is not the verdict above).

Status tracks the case-by-case re-evaluation: pending = not yet checked against the added-value test; confirmed = reviewed and the verdict holds.

External Library (UI-React)
Component

Files

shadcn coverage

JTL value-add

Status

Verdict

Why

accordion

7

atom

TBD

pending

alert

10

atom

TBD

pending

alert-dialog

7

atom

TBD

pending

annotated-section

4

none

TBD

pending

app-header

6

none

TBD

pending

avatar

8

atom

TBD

pending

badge

7

atom

TBD

pending

box

6

none

TBD

pending

breadcrumb

12

atom

TBD

pending

button

9

atom

TBD

pending

button-group

9

drop-in

TBD

pending

calendar

12

atom

TBD

pending

card

4

atom

TBD

pending

chart

16

drop-in

TBD

pending

checkbox

14

atom

TBD

pending

code-editor

13

none

TBD

pending

collapsible

6

atom

TBD

pending

color-picker

11

none

TBD

pending

combo-box

15

recipe-only

TBD

pending

command

29

atom

TBD

pending

context-menu

7

atom

TBD

pending

data-table

65

recipe-only, single-use

TBD

pending

date-picker

22

recipe-only

TBD

pending

date-range-picker

19

recipe-only

TBD

pending

dialog

13

atom

TBD

pending

dropdown

4

atom

TBD

pending

error-message

4

drop-in

TBD

pending

field

10

drop-in

TBD

pending

field-array

6

none

TBD

pending

file-upload

17

none

TBD

pending

form

13

atom

TBD

pending

form-group

7

none

TBD

pending

grid

13

none

TBD

pending

html-editor

71

none, single-use

TBD

pending

icon

16

drop-in

TBD

pending

input

13

atom

TBD

pending

input-group

27

drop-in

TBD

pending

input-otp

10

atom

TBD

pending

jtl-dropdown

13

drop-in

TBD

pending

jtl-logo

5

none

TBD

pending

kbd

10

drop-in

TBD

pending

label

7

atom

TBD

pending

layout

5

none

TBD

pending

layout-section

6

none

TBD

pending

link

8

none

TBD

pending

pagination

7

drop-in

TBD

pending

popover

4

atom

TBD

pending

progress

5

atom

TBD

pending

radio

9

atom

TBD

pending

scroll-area

3

atom

TBD

pending

select

12

atom

TBD

pending

separator

5

atom

TBD

pending

sheet

4

atom

TBD

pending

sidebar

13

atom

TBD

pending

simple-input

5

atom

TBD

pending

skeleton

6

atom

TBD

pending

stack

12

none

TBD

pending

stepper

15

none

TBD

pending

stepper-layout

15

none

TBD

pending

styled-icon

8

none

TBD

pending

switch

8

atom

TBD

pending

tab

7

atom

TBD

pending

table

29

drop-in

TBD

pending

tag

8

none (badge only)

TBD

pending

text

10

none

TBD

pending

textarea

6

atom

TBD

pending

toggle

10

atom

TBD

pending

toggle-group

20

atom

TBD

pending

Internal Library (Internal-React)
Component

Files

shadcn coverage

JTL value-add

Status

Verdict

Why

Appendix: shadcn registry type reference
The shadcn registry distributes many item types, not just components (docs). A type is mostly a routing instruction: it tells the CLI what kind of thing this is and where the files land in the consumer's project. Install is always copy-paste, so every type drops files the consumer then owns, except registry:theme, which writes CSS variables rather than files.

The full set, grouped by what they do.

Code that lands in the consumer's source tree

Type

What it actually is

Where it lands

Example

registry:ui

A single-file UI atom or small component. The atoms.

components/ui/

shadcn add button drops button.tsx.

registry:component

A simple component, one or a few files, no atom wiring to install. Lighter than a block.

components/

shadcn's hello-world.tsx.

registry:block

A multi-file working unit (main plus sub-parts and hooks). Names its atoms in registryDependencies, and the CLI installs those alongside it.

components/, plus its atoms in components/ui/

sidebar-07: six files plus the sidebar, breadcrumb, and other atoms.

registry:hook

A React hook.

hooks/

use-mobile.

registry:lib

A non-UI helper module: utils, formatters, a client.

lib/

the cn() helper in utils.ts.

registry:page

A full page or file-based route, shipped to a route path via target.

route dir (e.g. app/)

a ready-made dashboard page.

registry:file

An arbitrary file dropped at an explicit target path. The escape hatch for anything not code-shaped.

wherever target says

AGENTS.md, .editorconfig, .github/workflows/ci.yml.

registry:font

A font, wired into the project.

project font config

a brand typeface.

Configuration, not files in the tree

Type

What it actually is

How it's used

registry:theme

A set of design tokens (colors, radius, typography) as cssVars. Ships no files; the CLI writes the variables into :root and .dark.

The JTL theme. shadcn add @jtl/theme re-skins every shadcn atom at once.

registry:style

A full style variant (like new-york). Defines the base a project initializes from: base dependencies, Tailwind config, and which atoms or tokens come preinstalled.

Picked once at shadcn init. JTL would ship a style so new projects start themed.

registry:base

The foundation a whole design system extends from. The broadest unit, sitting under styles and themes.

Rarely authored by a consumer; the design-system-wide layer.

The catch-all

Type

What it actually is

How it's used

registry:item

A universal item with no fixed shape. Bundles files of any of the above types (each with its own target) plus registryDependencies. The generic container when a thing is not one clean component.

A "project conventions" item that drops AGENTS.md, .editorconfig, and a docs file in one install; a "CI setup" item that pulls a Prettier config and writes a workflow.

So JTL can ship far more than components: hooks (registry:hook), lib and utils (registry:lib), the JTL theme (registry:theme), fonts, and agent instructions or CI config bundled as a registry:item. The three JTL terms (Component, Block, Recipe) sit on top of these raw types.

Related
UI Registry: Repo and Hosting — the separate decision on where this registry's source lives and how it is hosted.

# JuliaBnG Documenter themes

Sepia and Black themes for the package documentation, matching the
landing page and Coauthors. They appear as "sepia" and "black" in each
manual's Settings → Theme menu.

- `_sepia.scss`, `_black.scss`: the palettes, in Catppuccin's 26 colour
  slots (`blue` is the link colour, `sky` its hover).
- `build.jl`: compiles each palette through Documenter's own
  `catppuccin.scss` template, so the themes cover every element the
  built-in ones do.
- `themes.js`: re-runs Documenter's theme swap once the extra
  stylesheets exist and adds the two entries to the theme picker.

Documenter's theme list is a constant, so each package loads the
themes as assets: `docs/make.jl` defines `JULIABNG_ASSETS` and passes
it to `Documenter.HTML(assets = ...)`, and the built files live in
`docs/src/assets/juliabng/`.

## Rebuilding

Needs an environment with Documenter, DocumenterTools and
`libsass_jll = "=3.6.4"`:

```sh
julia --project=ENV docs-themes/build.jl \
    --install ../BnGStructs ../Breeding.jl ../FisherWright \
              ../Mrode-4ed-examples.jl ../RelationshipMatrices ../BnGsim
```

Then commit `docs/src/assets/juliabng/` in each package. Rebuild after a
Documenter minor release that changes its SCSS.

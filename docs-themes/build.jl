# Build the JuliaBnG Sepia and Black Documenter themes and install them into
# the package docs.
#
#   julia docs-themes/build.jl [--install DIR...]
#
# Compiles out/juliabng-{sepia,black}.css from Documenter's own Catppuccin
# template (the version in this environment) with the palettes in _sepia.scss
# and _black.scss. With --install, copies the CSS and themes.js into
# DIR/docs/src/assets/juliabng/ for each package directory DIR.
#
# Needs an environment with Documenter, DocumenterTools and
# libsass_jll = "=3.6.4" (as Documenter's own theme build pins).

using Documenter, DocumenterTools

const HERE = @__DIR__
const OUT = joinpath(HERE, "out")
const TEMPLATE = joinpath(Documenter.HTMLWriter.ASSETS_SASS, "catppuccin.scss")

# name => (palette partial, is dark)
const THEMES = ["juliabng-sepia" => ("sepia", false), "juliabng-black" => ("black", true)]

function build()
    mkpath(OUT)
    tpl = read(TEMPLATE, String)
    occursin("\${CATPPUCCIN_FLAVOR}", tpl) || error("unexpected template: $TEMPLATE")
    for (name, (palette, dark)) in THEMES
        scss = replace(tpl,
            "\$themename: \"catppuccin-\${CATPPUCCIN_FLAVOR}\";" => "\$themename: \"$name\";",
            "@import \"catppuccin/\${CATPPUCCIN_FLAVOR}\";" => "@import \"$palette\";",
            "\${IS_DARK_THEME}" => string(dark),
            # Latte-only ANSI tweaks apply to the light theme
            "\"catppuccin-latte\"" => dark ? "\"catppuccin-latte\"" : "\"$name\"")
        occursin("\${", scss) && error("template placeholder left in $name")
        src = joinpath(HERE, "$name.scss")      # next to the partials for @import
        write(src, scss)
        try
            DocumenterTools.Themes.compile(src, joinpath(OUT, "$name.css"))
        finally
            rm(src)
        end
        @info "built $name.css"
    end
    cp(joinpath(HERE, "themes.js"), joinpath(OUT, "themes.js"); force = true)
end

function install(pkgdir)
    dst = joinpath(pkgdir, "docs", "src", "assets", "juliabng")
    mkpath(dst)
    for f in readdir(OUT)
        cp(joinpath(OUT, f), joinpath(dst, f); force = true)
    end
    @info "installed into $dst"
end

build()
i = findfirst(==("--install"), ARGS)
i === nothing || foreach(install, ARGS[i+1:end])

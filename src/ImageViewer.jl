module ImageViewer

using GLMakie
using ColorSchemes

export imview


function imview(imgin; color_map_menu=true)
    # create figure to draw in
    fig = Figure()
    # that will be the image
    ax = Axis(fig[1,2], alignmode=Inside(), xrectzoom=false, yrectzoom=false)
    ax.aspect = DataAspect()

    # for small widgets
    gl = fig[1,1, Left()] = GridLayout()

    # fix image layout
    colsize!(fig.layout, 1, Fixed(100))
    #rowsize!(fig.layout, 0, Fixed(900))


    # specialize for three dimensions
    if ndims(imgin) == 3
        depth = Slider(fig[2,2, Top()], range=axes(imgin, 3))
        rowsize!(fig.layout, 2, Fixed(10))
      

        img = lift(depth.value) do d 
            return view(imgin, :, :, d)
           #
        end

        img = add_γ_slider(gl[1,1], (1,), img)
        img = add_γ_slider(gl[2,1], (1,), img)
        
        h = heatmap!(ax, img, interpolate=false, tellheight=true)
        if color_map_menu
            cmap_menu = add_colormap_menu(gl[3,1], (1,))
            cmap = on(cmap_menu.selection) do s
                h.colormap = s
            end
        end
        cb = Colorbar(fig[1, 3], h, tellheight=true)

        fix_sizes_to_img(fig, ax)

    end
   
    return fig
end

function fix_sizes_to_img(fig, ax)
    rowsize!(fig.layout, 1, ax.scene.px_area[].widths[2])
    colsize!(fig.layout, 2, ax.scene.px_area[].widths[1])
end

function add_γ_slider(gr, pos, img)
    γ_r = γ_range()
    Label(gr[pos..., 1, Top()], "γ:", textsize=20, halign=:left, valign=:top)
    γ = Slider(gr[pos..., 1], range=γ_r, startvalue=1, width=100)
    γ_text = @lift to_str($(γ.value))
    Label(gr[pos..., 1, Top()], γ_text)
    img = @lift($img .^ eltype($img)($(γ.value)))
    return img
end


function add_colormap_menu(gr, pos;
            cmap_options=["curl", "thermal", "roma", "gist_rainbow", "hsv", "twilight"]
        )
       # ColorSchemes.curl.colors,
       #               ColorSchemes.thermal.colors,
       #               ColorSchemes.roma.colors,
       #               ColorSchemes.gist_rainbow.colors,
       #               ColorSchemes.hsv.colors,
       #               ColorSchemes.twilight.colors,
       #              ]


    Label(gr[pos..., 1, Top()], "Color Map")
    cmap = Menu(gr[pos..., 1], options=cmap_options)
    return cmap
end

function apply_gamma(img, γ)
    return img .^ γ
end


function γ_range()
    γ_range = 10.0 .^ (-2:0.05:1)
end


function to_str(x::AbstractFloat; digits=2)
    string(round(x, digits=digits))
end







function make_slidergrid!(fig, sliders; digits=2)
    lsgrid = labelslidergrid!(fig,
                              sliders.labels,
                              sliders.ranges,
                              formats = [x -> "$(round(x, digits=digits))"],
                              width = 50,
                              tellheight=false
            )

    fig[2, 1] = lsgrid.layout

    sliderobservables = [s.value for s in lsgrid.sliders]
end



end # module

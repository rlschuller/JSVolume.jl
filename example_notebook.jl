### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ b5b8a606-2fc1-448e-b1e0-bdb5b0203268
using JSON

# ╔═╡ 3971acc6-2b7d-11ec-02fc-c3c4044112a8
include("src/show_volume.jl")

# ╔═╡ fd0aa0d8-9eeb-47fa-bde7-767d0d3b9941
vdata2 = [z/128 + .3 * (rand() - .5) for x in 1:128, y in 1:128, z in 1:128];

# ╔═╡ 99a6c6c4-b322-476a-aec9-fa828447c3b4
show_volume(vdata2; default_renderstyle="mip")

# ╔═╡ f1f49f78-3ceb-4964-85d1-24afe5000aed
io = open("vol.flat", "r");

# ╔═╡ e0279c1c-9cbf-4b7a-a1d8-62421e97cea0
s = read(io, String);

# ╔═╡ dcb8f2ef-288d-4388-92ff-8f4179f8e4c2
data = JSON.parse(s);

# ╔═╡ 6b79fe45-c141-47e5-b98a-c3ea1f95f97a
vdata = Array{Float64, 3}(reshape(data, 128, 128, 256));

# ╔═╡ be28a9f7-c96a-4d01-a593-6430da4e38c1
show_volume(vdata; cmap=[(i==1)*(j-1) + (i==3)*(256-j) for i in 1:3, j in 1:256], default_cmap="custom", clim1=0, clim2=1, default_renderstyle="iso", isothreshold=.08)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"

[compat]
JSON = "~0.21.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "a8709b968a1ea6abc2dc1967cb1db6ac9a00dfb6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.5"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╠═3971acc6-2b7d-11ec-02fc-c3c4044112a8
# ╠═fd0aa0d8-9eeb-47fa-bde7-767d0d3b9941
# ╠═99a6c6c4-b322-476a-aec9-fa828447c3b4
# ╠═b5b8a606-2fc1-448e-b1e0-bdb5b0203268
# ╠═f1f49f78-3ceb-4964-85d1-24afe5000aed
# ╠═e0279c1c-9cbf-4b7a-a1d8-62421e97cea0
# ╠═dcb8f2ef-288d-4388-92ff-8f4179f8e4c2
# ╠═6b79fe45-c141-47e5-b98a-c3ea1f95f97a
# ╠═be28a9f7-c96a-4d01-a593-6430da4e38c1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

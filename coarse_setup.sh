# install uv and python 3.12

# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# # Windows
# powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"


uv python install 3.12

uv tool install coarse-ink

coarse setup #store keys in ~/.coarse/config.toml


#run

coarse-review paper.pdf --host claude

# Shared economy model directory

This directory is intended to hold the single editable Mechflow model for the Ceres economy. Start Mechflow with `tools/run_mechflow.sh` so its model browser reads and edits this directory directly. Do not keep a second copy under the Mechflow checkout.

The Godot runtime reads generated `ceres-water.runtime.json`; `tools/run_mechflow.sh` regenerates it automatically whenever the YAML changes. Do not edit the generated JSON by hand. The current mapping is a demo, not an approved Ceres colony model. See `docs/mechflow-workspace.md` for the data contract and limits.

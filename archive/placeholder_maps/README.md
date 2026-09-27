# Retired flat prototypes

These two VMAP files produced the broken flat map reported on 27 September 2026.
They are retained for recovery with a `.disabled` extension, outside the content
build tree. Do not restore them to `content/maps` or compile them over production.

The active local map is the previously selected Survival layout, restored by
`node tools/build_map_theme.mjs`. Verify it with `node tools/check_map.mjs`.
Both supported launch names intentionally use the same recorded playable map.
The compiled local reference map is not an editable source for future original
map development; a replacement requires its own reviewed source and manifest.

Do not run `tools/build_master_map.mjs --allow-placeholder-map` against this
checkout: that explicit override is only for a separate prototype workspace.

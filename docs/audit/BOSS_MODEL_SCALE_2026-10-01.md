# Boss model scale — 2026-10-01

Owner asks arriving Bosses to be twice their normal size. Runtime currently spawns12 roster hero entities via WaveManager, then BossFramework.PrepareBoss delegates to NativeHeroBosses.Prepare. Old themed-unit KV ModelScale values are not used for these native hero visuals. The preparation path had no visual enlargement; editing legacy template scales would not address the current spawn path.

NativeBosses.MODEL_SCALE_MULTIPLIER=2 is applied after successful kit/level/item preparation. Each entity's initial GetModelScale is stored once as bossBaseModelScale, then SetModelScale(base×2). No unconditional scale2 override, per-frame update or compounding on repeated preparation. Only prepared Boss entities pass this path; no normal creep/player/Summon scaling change. HP, damage, skill values and map collision settings were not edited.

MCP verifies CBaseModelEntity.GetModelScale():float and SetModelScale(scale:float), server only. CBaseEntity lookup was rejected and corrected to the actual owning class. [ModDota API](https://docs.moddota.com/lua_server/declaration) corroborates these signatures; unrelated Source1 SDK results were not used as Dota Source2 behavior evidence. No external code/assets imported.

Existing preparation regression extended: baseline0.8 becomes1.6 and repeated setup stays1.6. Installed-data native Boss audit verifies all12 successfully prepared entities get2 from baseline1. npm run check passes with zero failed checks, including220 hero regressions and200 ability/223 modifier smoke. Current installed build6942. These are mock/API checks, not visual engine acceptance.

Result: IMPLEMENTED BUT NOT ENGINE-VERIFIED. Owner must check first Boss size/readability, Dragon Knight model transformation, wearable/particle attachments and VConsole. No Dota launch/control, NVIDIA investigation, remote Git push or Workshop publication. Local changes only.

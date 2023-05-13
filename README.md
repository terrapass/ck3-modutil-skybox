Map Skybox
==========
_(a Crusader Kings III modding utility)_

This repository contains CK3 mod files which implement sky rendering on the map.
<a name="demo"></a>

![Animated GIF with camera rotating around and showing sky above the terrain](https://media.githubusercontent.com/media/terrapass/ck3-modutil-skybox/master/docs/skybox_demo.gif)

You can integrate this feature into your own mod by copying the files into your mod's file structure and making adjustments if necessary (see [Integrating into Your Mod](#integration)).
Alternatively, you can load the contents of this repo as a separate mod in your playset, which might be useful if you just want to take several beauty shots of the map, `mod/descriptor.mod` is provided for this purpose.

**The code has been updated to be compatible with CK3 version 1.9.0 (Lance).**

Table of Contents
-----------------
1. <a href="#description">Description</a>
2. <a href="#integration">Integrating into Your Mod</a>
3. <a href="#large-maps">Tweaks for Larger Maps</a>
4. <a href="#under-the-hood">Under the Hood</a>

Description<a name="description"></a>
-----------
The sky is rendered via a skybox - a 6-sided box mesh with normals pointing inwards, which is placed as an object on the map,
and to which a special sky pixel shader is applied. Game camera is unlocked (its min. angle is set to 0 via a define) to be able to actually look at the sky
and appreciate its beauty. Additionally, shader files in this repo also contain Buck's fixes for borders and horizon rendering through the terrain,
as well as a version of sky shader suitable for use in court room scenes.

Integrating into Your Mod<a name="integration"></a>
-------------------------
Use the following steps to integrate map sky rendering into your mod.

1. Copy the contents of `gfx/models/mapitems` and `gfx/map/map_object_data` into your mod's file structure.

2. Copy all of the `.shader` files that don't yet exist in your mod from `gfx/FX`.
If your mod already has some of these shader files, you'll need to manually merge in changes from this repo's versions of these files into yours.

For convenience, all the changes necessary for map sky rendering are marked with `MOD(map-skybox)` comments in `.shader` files -
you can just search for this string and copy/replace all pieces of code surrounded by this comment.
Additionally, `MOD(court-skybox)` comments in `court_scene.shader` mark changes providing support for sky rendering in court room scene.

3. Copy `gfx/map/environment/SkyBox.dds` from this repo, if you want to use the sky texture it provides (can be seen in the [demo GIF](#demo)).

<a name="integration.custom-skybox"></a>Alternatively, you can either take one of the cubemap images included in vanilla game (from vanilla `gfx/map/environment` or `gfx/portraits/environments` folders),
or create your own skybox image and save it as `gfx/map/environment/SkyBox.dds`.

If going the latter route, make sure that your custom `SkyBox.dds` is using `BC1/DX1` format and is saved as a cubemap ("Cube&nbsp;Map&nbsp;from&nbsp;crossed&nbsp;image" in Paint.NET)
with mip-maps enabled.

4. Copy `common/defines/graphic/SKYX_defines.txt` from this repo, unless your mod already modifies `ZFAR` or `ZOOM_STEPS_MIN_TILT` defines.

5. If your mod's map size is the same as vanilla (`8192x4096`) or smaller, you're all set. Otherwise see [the next section](#large-maps).

Tweaks for Larger Maps<a name="large-maps"></a>
----------------------

If your map is larger than vanilla (as specified via `WORLD_EXTENTS_X` and `WORLD_EXTENTS_Z` defines), you'll need to modify a couple of things.

1. Either via mapeditor or by manually modifying `gfx/map/map_object_data/SKYX_skybox.txt` with a text editor,
move the `SKYX_skybox` mesh to the middle of your map and resize it along X and Z axes so that it's a bit bigger than your map.

If you choose to use a text editor, you can do this by finding the line with `transform=` in `gfx/map/map_object_data/SKYX_skybox.txt` and changing the numbers there as follows:
| Existing Number | Change to                             |
| --------------- | --------------------------------------|
| `4096.0`        | your `WORLD_EXTENTS_X` divided by `2` |
| `2048.0`        | your `WORLD_EXTENTS_Z` divided by `2` |
| `10000.0`       | your `WORLD_EXTENTS_X` plus `1000`    |
| `5000.0`        | your `WORLD_EXTENTS_Z` plus `1000`    |

2. Change `ZFAR` define in `common/defines/graphic/SKYX_defines.txt` (or your own defines file) to be about `1.5` times bigger than the larger of your map's sides.

So, for example, if your map dimensions are `10000x20000`, set your `ZFAR` to `30000`.

This is needed so that the skybox mesh is not clipped by the camera's far clipping plane when rendering,
otherwise you'll see a black artifact when looking from one corner of the map at the opposite one.

So if you see something like this, it's probably due to your `ZFAR` being too small.
![Example of an artifact caused by low ZFAR setting](https://media.githubusercontent.com/media/terrapass/ck3-modutil-skybox/master/docs/zfar_artifact_example.png)

Under the Hood<a name="under-the-hood"></a>
--------------

Below is a short summary of the files included in this repo and the purpose they serve.

* `gfx/models/mapitems/SKYX_skybox.mesh` - the actual skybox mesh - a cube with inverted normals, `2.0` units in each dimension, origin in the center.
* `gfx/models/mapitems/SKYX_skybox.asset` - asset file defining `SKYX_skybox_mesh` based on the above mesh file and specifying `SKYX_sky` shader effect for it.
* `gfx/map/environment/SkyBox.dds` - cubemap texture used for the sky, may be replaced by a custom one as described [above](#integration.custom-skybox).
* `gfx/map/map_object_data/SKYX_skybox.txt` - map data file, placing a single instance of the `SKYX_skybox_mesh` in the middle of the map and scaling it to enclose the entire map; needs to be modified for larger-than-vanilla maps as described [above](#large-maps).
* `gfx/FX` contains modified vanilla shader files, which introduce the following changes necessary to properly render the skybox.
  * `pdxmesh.shader` - defines `SKYX_sky` shader effect used to render the map skybox using the cubemap texture in `SkyBox.dds`.
  * `court_scene.shader` - defines `SKYX_court_sky` shader effect, which can be used to render skyboxes in court room scenes based on `cubemap` specified in their scene settings files.
  * `pdxborder.shader` - prevents borders from being rendered through terrain.
  * `surroundmap.shader` - prevents black line on the horizon from being rendered through terrain.
  * `pdxwater.shader` - removes black spaces along map edges with no water to prevent them from ruining the sky effect.
* `common/defines/graphic/SKYX_defines.txt` - changes camera-related defines to unlock map camera angles and moves far clipping plane further from the camera; needs to be modified for larger-than-vanilla maps as described [above](#large-maps).

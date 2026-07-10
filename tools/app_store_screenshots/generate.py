#!/usr/bin/env python3
"""Batch generator for Rodizio de Brinquedos App Store screenshots."""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Any

import yaml

from compose import DEFAULT_DEVICE_SPECS, DeviceSpec, SceneSpec, compose_scene
from showcase import create_showcase


CONFIG_BY_LOCALE = {
    "pt-br": "pt_br.yaml",
    "pt_br": "pt_br.yaml",
    "pt": "pt_br.yaml",
    "en-us": "en_us.yaml",
    "en_us": "en_us.yaml",
    "en": "en_us.yaml",
}


def parse_size(value: str) -> tuple[int, int]:
    match = re.fullmatch(r"(\d+)x(\d+)", value.strip().lower())
    if not match:
        raise argparse.ArgumentTypeError("Size must use WIDTHxHEIGHT, e.g. 1290x2796.")
    return int(match.group(1)), int(match.group(2))


def locale_key(value: str) -> str:
    return value.strip().lower().replace("_", "-")


def config_path_for(locale: str, config_dir: Path) -> Path:
    key = locale_key(locale)
    filename = CONFIG_BY_LOCALE.get(key)
    if filename is None:
        supported = ", ".join(sorted({"pt-BR", "en-US"}))
        raise SystemExit(f"Unsupported locale '{locale}'. Supported: {supported}.")
    return config_dir / filename


def load_config(locale: str, config_dir: Path) -> dict[str, Any]:
    path = config_path_for(locale, config_dir)
    if not path.exists():
        raise SystemExit(f"Config not found: {path}")
    with path.open("r", encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def normalized_locale_dir(locale: str, config: dict[str, Any]) -> str:
    configured = config.get("locale")
    if configured:
        return str(configured)
    key = locale_key(locale)
    if key == "pt-br" or key == "pt":
        return "pt-BR"
    if key == "en-us" or key == "en":
        return "en-US"
    return locale


def device_spec(config: dict[str, Any], device: str) -> DeviceSpec:
    defaults = DEFAULT_DEVICE_SPECS[device]
    values = config.get("devices", {}).get(device, {})
    return DeviceSpec(
        name=device,
        frame_width_ratio=float(values.get("frame_width_ratio", defaults.frame_width_ratio)),
        frame_top_ratio=float(values.get("frame_top_ratio", defaults.frame_top_ratio)),
        corner_radius_ratio=float(values.get("corner_radius_ratio", defaults.corner_radius_ratio)),
    )


def find_input(
    input_root: Path,
    locale_dir: str,
    device: str,
    source: str,
) -> Path | None:
    candidates = [
        input_root / locale_dir / device / source,
        input_root / device / source,
        input_root / source,
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return None


def slug(index: int, scene_id: str) -> str:
    cleaned = re.sub(r"[^a-z0-9]+", "-", scene_id.lower()).strip("-")
    return f"{index:02d}-{cleaned or 'screenshot'}.png"


def generate(
    *,
    locale: str,
    device: str,
    size: tuple[int, int],
    config_dir: Path,
    input_root: Path,
    output_root: Path,
    scene_filter: str | None,
    make_showcase: bool,
) -> list[Path]:
    config = load_config(locale, config_dir)
    output_locale = config["locale"]
    input_locale = normalized_locale_dir(locale, config)
    brand = config.get("brand", {})
    spec = device_spec(config, device)
    scenes = config.get("scenes", [])
    if scene_filter:
        scenes = [scene for scene in scenes if scene.get("id") == scene_filter]
        if not scenes:
            raise SystemExit(f"Scene not found in config: {scene_filter}")

    final_dir = output_root / output_locale / device
    generated: list[Path] = []
    missing: list[str] = []
    selected_scenes = [
        scene
        for scene in scenes
        if find_input(input_root, input_locale, device, scene["source"])
        is not None
    ]

    for scene in scenes:
        input_path = find_input(input_root, input_locale, device, scene["source"])
        if input_path is None:
            missing.append(f"{input_locale}/{device}/{scene['source']}")
            continue
        index = len(generated) + 1
        scene_spec = SceneSpec(
            title=scene["title"],
            subtitle=scene.get("subtitle", ""),
            screenshot_path=input_path,
            output_path=final_dir / slug(index, scene["id"]),
            index=index,
            total=len(selected_scenes),
        )
        output = compose_scene(scene_spec, device=spec, brand=brand, size=size)
        generated.append(output)
        print(f"Generated {output}")

    if missing:
        print("Skipped missing simulator screenshots:")
        for item in missing:
            print(f"  - {input_root / item}")

    if not generated:
        raise SystemExit(
            "No screenshots generated. Add simulator PNGs to "
            "input/<locale>/<device>/, keep legacy input/<device>/ files, "
            "or pass --input-root pointing to an existing screenshot folder."
        )

    if make_showcase:
        showcase_path = output_root.parent / f"showcase_{output_locale}_{device}.png"
        create_showcase(
            generated,
            showcase_path,
            title=f"Rodizio de Brinquedos - {output_locale} - {device}",
        )
        print(f"Generated showcase {showcase_path}")

    return generated


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate localized App Store screenshots.")
    parser.add_argument("--locale", required=True, help="pt-BR or en-US")
    parser.add_argument("--device", required=True, choices=("iphone", "ipad"))
    parser.add_argument("--size", required=True, type=parse_size, help="WIDTHxHEIGHT, e.g. 1290x2796")
    parser.add_argument("--config-dir", type=Path, default=Path("config"))
    parser.add_argument("--input-root", type=Path, default=Path("input"))
    parser.add_argument("--output-root", type=Path, default=Path("output/final"))
    parser.add_argument("--scene", help="Generate only one scene id from the locale config.")
    parser.add_argument("--no-showcase", action="store_true", help="Skip showcase generation.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    generate(
        locale=args.locale,
        device=args.device,
        size=args.size,
        config_dir=args.config_dir,
        input_root=args.input_root,
        output_root=args.output_root,
        scene_filter=args.scene,
        make_showcase=not args.no_showcase,
    )


if __name__ == "__main__":
    main()

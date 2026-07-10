#!/usr/bin/env python3
"""Generate a review showcase with final screenshots side by side."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def load_font(size: int) -> ImageFont.ImageFont:
    for candidate in (
        "/System/Library/Fonts/Supplemental/Avenir Next.ttc",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial.ttf",
    ):
        path = Path(candidate)
        if path.exists():
            try:
                return ImageFont.truetype(str(path), size=size)
            except OSError:
                continue
    return ImageFont.load_default()


def create_showcase(
    screenshots: list[Path],
    output_path: Path,
    *,
    title: str | None = None,
    thumb_height: int = 820,
) -> Path:
    if not screenshots:
        raise ValueError("No screenshots provided for showcase.")

    images = [Image.open(path).convert("RGBA") for path in screenshots]
    scaled: list[Image.Image] = []
    for image in images:
        ratio = thumb_height / image.height
        scaled.append(
            image.resize((int(image.width * ratio), thumb_height), Image.Resampling.LANCZOS)
        )

    padding = 56
    gap = 32
    title_h = 92 if title else 0
    total_w = sum(image.width for image in scaled) + gap * (len(scaled) - 1) + padding * 2
    total_h = thumb_height + padding * 2 + title_h
    canvas = Image.new("RGB", (total_w, total_h), "#F8FAFC")
    draw = ImageDraw.Draw(canvas)

    if title:
        font = load_font(34)
        bbox = draw.textbbox((0, 0), title, font=font)
        draw.text(((total_w - (bbox[2] - bbox[0])) // 2, padding // 2), title, fill="#263832", font=font)

    x = padding
    y = padding + title_h
    for image in scaled:
        shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        shadow_draw = ImageDraw.Draw(shadow)
        shadow_draw.rounded_rectangle(
            (x + 8, y + 12, x + image.width + 8, y + image.height + 12),
            radius=28,
            fill=(38, 56, 50, 28),
        )
        canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow).convert("RGB")
        canvas.paste(image.convert("RGB"), (x, y))
        x += image.width + gap

    output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output_path, "PNG", optimize=True)
    return output_path


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create an App Store screenshot showcase.")
    parser.add_argument("--screenshots", nargs="+", type=Path, help="Final screenshots to include.")
    parser.add_argument("--locale", help="Locale folder to scan, e.g. pt-BR or en-US.")
    parser.add_argument("--device", choices=("iphone", "ipad"), help="Device folder to scan.")
    parser.add_argument("--input-dir", type=Path, default=Path("output/final"))
    parser.add_argument("--output", type=Path)
    parser.add_argument("--title")
    return parser.parse_args()


def main() -> None:
    args = _parse_args()
    if args.screenshots:
        screenshots = args.screenshots
    elif args.locale and args.device:
        screenshots = sorted((args.input_dir / args.locale / args.device).glob("*.png"))
    else:
        raise SystemExit("Provide --screenshots or both --locale and --device.")

    output = args.output
    if output is None:
        if not (args.locale and args.device):
            raise SystemExit("--output is required when --locale/--device are not provided.")
        output = Path("output") / f"showcase_{args.locale}_{args.device}.png"

    path = create_showcase(screenshots, output, title=args.title)
    print(f"Generated showcase: {path}")


if __name__ == "__main__":
    main()

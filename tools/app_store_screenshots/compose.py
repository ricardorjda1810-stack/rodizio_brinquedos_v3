#!/usr/bin/env python3
"""Deterministic App Store screenshot composition for Rodizio de Brinquedos.

The composer takes a real simulator screenshot and places it inside a clean
device frame with localized marketing copy. It intentionally avoids runtime
Flutter dependencies and AI-only steps so the output is reproducible locally.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


@dataclass(frozen=True)
class DeviceSpec:
    name: str
    frame_width_ratio: float
    frame_top_ratio: float
    corner_radius_ratio: float


@dataclass(frozen=True)
class SceneSpec:
    title: str
    subtitle: str
    screenshot_path: Path
    output_path: Path
    index: int
    total: int


DEFAULT_DEVICE_SPECS = {
    "iphone": DeviceSpec(
        name="iphone",
        frame_width_ratio=0.70,
        frame_top_ratio=0.34,
        corner_radius_ratio=0.095,
    ),
    "ipad": DeviceSpec(
        name="ipad",
        frame_width_ratio=0.82,
        frame_top_ratio=0.33,
        corner_radius_ratio=0.050,
    ),
}


FONT_CANDIDATES = (
    "/System/Library/Fonts/Supplemental/Avenir Next.ttc",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/Library/Fonts/Arial Bold.ttf",
    "/System/Library/Fonts/SFNS.ttf",
)

REGULAR_FONT_CANDIDATES = (
    "/System/Library/Fonts/Supplemental/Avenir Next.ttc",
    "/System/Library/Fonts/Supplemental/Arial.ttf",
    "/Library/Fonts/Arial.ttf",
    "/System/Library/Fonts/SFNS.ttf",
)


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    cleaned = value.strip().lstrip("#")
    if len(cleaned) != 6:
        raise ValueError(f"Invalid hex colour: {value}")
    return tuple(int(cleaned[i : i + 2], 16) for i in (0, 2, 4))


def load_font(size: int, *, bold: bool = False) -> ImageFont.ImageFont:
    candidates = FONT_CANDIDATES if bold else REGULAR_FONT_CANDIDATES
    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            try:
                return ImageFont.truetype(str(path), size=size)
            except OSError:
                continue
    return ImageFont.load_default()


def text_size(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont) -> tuple[int, int]:
    bbox = draw.textbbox((0, 0), text, font=font)
    return bbox[2] - bbox[0], bbox[3] - bbox[1]


def wrap_text(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.ImageFont,
    max_width: int,
) -> list[str]:
    words = text.split()
    if not words:
        return []
    lines: list[str] = []
    current = ""
    for word in words:
        candidate = f"{current} {word}".strip()
        if text_size(draw, candidate, font)[0] <= max_width:
            current = candidate
            continue
        if current:
            lines.append(current)
        current = word
    if current:
        lines.append(current)
    return lines


def font_to_fit(
    draw: ImageDraw.ImageDraw,
    text: str,
    max_width: int,
    max_size: int,
    min_size: int,
    *,
    bold: bool,
) -> ImageFont.ImageFont:
    for size in range(max_size, min_size - 1, -2):
        font = load_font(size, bold=bold)
        if all(text_size(draw, line, font)[0] <= max_width for line in wrap_text(draw, text, font, max_width)):
            return font
    return load_font(min_size, bold=bold)


def draw_centered_lines(
    draw: ImageDraw.ImageDraw,
    lines: Iterable[str],
    font: ImageFont.ImageFont,
    y: int,
    fill: str,
    line_gap: int,
    canvas_width: int,
) -> int:
    for line in lines:
        width, height = text_size(draw, line, font)
        draw.text(((canvas_width - width) // 2, y), line, font=font, fill=fill)
        y += height + line_gap
    return y


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1),
        radius=radius,
        fill=255,
    )
    return mask


def fit_cover(image: Image.Image, target_size: tuple[int, int]) -> Image.Image:
    target_w, target_h = target_size
    scale = max(target_w / image.width, target_h / image.height)
    resized = image.resize(
        (int(image.width * scale), int(image.height * scale)),
        Image.Resampling.LANCZOS,
    )
    left = max(0, (resized.width - target_w) // 2)
    top = max(0, (resized.height - target_h) // 2)
    return resized.crop((left, top, left + target_w, top + target_h))


def draw_device(
    canvas: Image.Image,
    screenshot_path: Path,
    device: DeviceSpec,
    brand: dict[str, str],
    size: tuple[int, int],
) -> None:
    canvas_w, canvas_h = size
    draw = ImageDraw.Draw(canvas)
    screenshot = Image.open(screenshot_path).convert("RGBA")

    frame_w = int(canvas_w * device.frame_width_ratio)
    screen_ratio = screenshot.height / screenshot.width
    frame_h = int(frame_w * screen_ratio)
    max_frame_h = int(canvas_h * 0.70)
    if frame_h > max_frame_h:
        frame_h = max_frame_h
        frame_w = int(frame_h / screen_ratio)

    frame_x = (canvas_w - frame_w) // 2
    frame_y = int(canvas_h * device.frame_top_ratio)
    radius = int(frame_w * device.corner_radius_ratio)
    bezel = max(12, int(frame_w * (0.030 if device.name == "iphone" else 0.020)))
    screen_x = frame_x + bezel
    screen_y = frame_y + bezel
    screen_w = frame_w - bezel * 2
    screen_h = frame_h - bezel * 2

    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        (frame_x + 10, frame_y + 18, frame_x + frame_w + 10, frame_y + frame_h + 18),
        radius=radius,
        fill=(38, 56, 50, 42),
    )
    canvas.alpha_composite(shadow)

    draw.rounded_rectangle(
        (frame_x, frame_y, frame_x + frame_w, frame_y + frame_h),
        radius=radius,
        fill=brand.get("frame", "#1F2933"),
    )

    screen = fit_cover(screenshot, (screen_w, screen_h))
    mask = rounded_mask((screen_w, screen_h), max(18, radius - bezel))
    canvas.paste(screen, (screen_x, screen_y), mask)

    if device.name == "iphone":
        island_w = int(screen_w * 0.28)
        island_h = max(20, int(screen_w * 0.038))
        island_x = screen_x + (screen_w - island_w) // 2
        island_y = screen_y + max(12, int(screen_w * 0.035))
        draw.rounded_rectangle(
            (island_x, island_y, island_x + island_w, island_y + island_h),
            radius=island_h // 2,
            fill=(22, 28, 35),
        )


def draw_background(canvas: Image.Image, brand: dict[str, str], size: tuple[int, int]) -> None:
    canvas_w, canvas_h = size
    draw = ImageDraw.Draw(canvas)
    accent = brand.get("accent", "#FF6B17")
    accent_dark = brand.get("accent_dark", "#D94E0B")

    top_band_h = int(canvas_h * 0.29)
    draw.rounded_rectangle(
        (-int(canvas_w * 0.12), -int(canvas_h * 0.06), int(canvas_w * 1.12), top_band_h),
        radius=int(canvas_w * 0.08),
        fill=accent,
    )
    stripe_h = max(18, int(canvas_h * 0.008))
    draw.rectangle(
        (0, top_band_h - stripe_h // 2, canvas_w, top_band_h + stripe_h // 2),
        fill=accent_dark,
    )


def compose_scene(
    scene: SceneSpec,
    *,
    device: DeviceSpec,
    brand: dict[str, str],
    size: tuple[int, int],
) -> Path:
    canvas = Image.new("RGBA", size, (*hex_to_rgb(brand.get("background", "#FFF7ED")), 255))
    draw_background(canvas, brand, size)
    draw = ImageDraw.Draw(canvas)
    canvas_w, canvas_h = size

    headline_colour = brand.get("headline", "#263832")
    subtitle_colour = brand.get("subtitle", "#6B5A48")
    headline_max_w = int(canvas_w * 0.78)
    subtitle_max_w = int(canvas_w * 0.76)
    headline_font = font_to_fit(
        draw,
        scene.title,
        headline_max_w,
        max_size=max(54, int(canvas_h * 0.045)),
        min_size=max(32, int(canvas_h * 0.022)),
        bold=True,
    )
    subtitle_font = font_to_fit(
        draw,
        scene.subtitle,
        subtitle_max_w,
        max_size=max(30, int(canvas_h * 0.020)),
        min_size=max(20, int(canvas_h * 0.013)),
        bold=False,
    )
    headline_lines = wrap_text(draw, scene.title, headline_font, headline_max_w)
    subtitle_lines = wrap_text(draw, scene.subtitle, subtitle_font, subtitle_max_w)

    y = int(canvas_h * 0.060)
    y = draw_centered_lines(
        draw,
        headline_lines,
        headline_font,
        y,
        headline_colour,
        line_gap=max(10, int(canvas_h * 0.006)),
        canvas_width=canvas_w,
    )
    y += max(10, int(canvas_h * 0.006))
    draw_centered_lines(
        draw,
        subtitle_lines,
        subtitle_font,
        y,
        subtitle_colour,
        line_gap=max(8, int(canvas_h * 0.004)),
        canvas_width=canvas_w,
    )

    draw_device(canvas, scene.screenshot_path, device, brand, size)

    scene.output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(scene.output_path, "PNG", optimize=True)
    return scene.output_path

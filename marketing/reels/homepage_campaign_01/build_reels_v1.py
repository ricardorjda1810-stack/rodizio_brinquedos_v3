#!/usr/bin/env python3
"""Build an automatic V1 Reels video for the homepage campaign.

Requires FFmpeg in PATH.
Input assets live in ./assets_input.
Final MP4 is written to ./output/reels_rodizio_homepage_v1.mp4.
"""

from __future__ import annotations

import shlex
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parent
ASSETS_DIR = ROOT / "assets_input"
OUTPUT_DIR = ROOT / "output"
TMP_DIR = OUTPUT_DIR / "_tmp_reels_v1"
FINAL_VIDEO = OUTPUT_DIR / "reels_rodizio_homepage_v1.mp4"

WIDTH = 1080
HEIGHT = 1920
FPS = 30

SCENES = [
    {
        "file": "asset_01_muitos_brinquedos.png",
        "duration": 3.5,
        "text": "Muitos brinquedos...",
        "effect": "zoom",
    },
    {
        "file": "asset_02_crianca_sem_foco.png",
        "duration": 4.0,
        "text": "...e mesmo assim brinca pouco?",
        "effect": "pan_right",
    },
    {
        "file": "asset_03_pouco_engajamento.png",
        "duration": 4.5,
        "text": "Muitas opções. Pouco interesse.",
        "effect": "zoom",
    },
    {
        "file": "asset_04_mae_organizando.png",
        "duration": 4.0,
        "text": "Tente o rodízio de brinquedos",
        "effect": "pan_left",
    },
    {
        "file": "asset_05_ambiente_organizado.png",
        "duration": 4.0,
        "text": "Menos bagunça. Mais clareza.",
        "effect": "zoom",
    },
    {
        "file": "asset_06_crianca_brincando_com_foco.png",
        "duration": 4.5,
        "text": "Mais valor em cada brincadeira",
        "effect": "zoom",
    },
    {
        "file": "asset_07_mockup_app.png",
        "duration": 4.0,
        "text": "Organize tudo com o app",
        "effect": "zoom",
    },
    {
        "file": "asset_08_tela_final_cta.png",
        "duration": 5.0,
        "text": "Entenda o Rodízio de Brinquedos\nno link da homepage",
        "effect": "still",
    },
]


def run(command: list[str]) -> None:
    printable = " ".join(shlex.quote(part) for part in command)
    print(f"\n$ {printable}")
    subprocess.run(command, check=True)


def require_ffmpeg() -> None:
    if shutil.which("ffmpeg"):
        return

    print("ERRO: FFmpeg não foi encontrado no PATH.")
    print()
    print("Instale ou configure o FFmpeg antes de gerar o vídeo.")
    print("No macOS com Homebrew:")
    print("  brew install ffmpeg")
    print()
    print("Depois rode novamente:")
    print("  python3 marketing/reels/homepage_campaign_01/build_reels_v1.py")
    raise SystemExit(1)


def validate_assets() -> None:
    missing = [scene["file"] for scene in SCENES if not (ASSETS_DIR / scene["file"]).exists()]
    if not missing:
        return

    print("ERRO: faltam assets obrigatórios em:")
    print(f"  {ASSETS_DIR}")
    print()
    for filename in missing:
        print(f"- {filename}")
    print()
    print("Coloque os 8 PNGs nessa pasta com os nomes esperados e rode o script novamente.")
    raise SystemExit(1)


def shell_escape_filter_text(text: str) -> str:
    # FFmpeg drawtext escaping. Keep this intentionally conservative.
    return (
        text.replace("\\", "\\\\")
        .replace(":", "\\:")
        .replace("'", "\\'")
        .replace("%", "\\%")
        .replace("\n", "\\n")
    )


def base_scale_filter() -> str:
    return (
        f"scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,"
        f"crop={WIDTH}:{HEIGHT},setsar=1"
    )


def motion_filter(effect: str, frames: int) -> str:
    # Build motion after scaling to a larger canvas, then crop back to 1080x1920.
    large_w = 1188
    large_h = 2112
    if effect == "pan_right":
        x_expr = f"({large_w}-{WIDTH})*n/{max(frames - 1, 1)}"
        y_expr = f"({large_h}-{HEIGHT})/2"
    elif effect == "pan_left":
        x_expr = f"({large_w}-{WIDTH})*(1-n/{max(frames - 1, 1)})"
        y_expr = f"({large_h}-{HEIGHT})/2"
    elif effect == "still":
        x_expr = f"({large_w}-{WIDTH})/2"
        y_expr = f"({large_h}-{HEIGHT})/2"
    else:
        # Slow zoom by scaling up across the clip.
        x_expr = f"({large_w}-{WIDTH})/2"
        y_expr = f"({large_h}-{HEIGHT})/2"

    zoom = (
        f"scale={large_w}:{large_h}:force_original_aspect_ratio=increase,"
        f"crop={large_w}:{large_h},"
    )
    if effect == "zoom":
        zoom += (
            f"zoompan=z='1+0.08*on/{max(frames - 1, 1)}':"
            f"x='iw/2-(iw/zoom/2)':"
            f"y='ih/2-(ih/zoom/2)':"
            f"d=1:s={WIDTH}x{HEIGHT}:fps={FPS}"
        )
    else:
        zoom += f"crop={WIDTH}:{HEIGHT}:x='{x_expr}':y='{y_expr}':eval=frame"
    return zoom


def draw_text_filter(text: str) -> str:
    escaped = shell_escape_filter_text(text)
    # Try system fonts commonly available on macOS. FFmpeg will fail clearly if none exist.
    font_candidates = [
        "/System/Library/Fonts/Supplemental/Avenir Next.ttc",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/Library/Fonts/Arial Bold.ttf",
    ]
    font = next((path for path in font_candidates if Path(path).exists()), "")
    font_part = f"fontfile='{font}':" if font else ""
    return (
        "drawtext="
        f"{font_part}"
        f"text='{escaped}':"
        "fontcolor=0x2D211B:"
        "fontsize=58:"
        "line_spacing=12:"
        "box=1:"
        "boxcolor=0xFFFAF1@0.78:"
        "boxborderw=28:"
        "shadowcolor=0x000000@0.25:"
        "shadowx=0:"
        "shadowy=3:"
        "x=(w-text_w)/2:"
        "y=170"
    )


def render_scene(scene: dict[str, object], index: int) -> Path:
    duration = float(scene["duration"])
    frames = round(duration * FPS)
    clip_path = TMP_DIR / f"scene_{index:02d}.mp4"
    image_path = ASSETS_DIR / str(scene["file"])
    vf = (
        f"{motion_filter(str(scene['effect']), frames)},"
        f"{draw_text_filter(str(scene['text']))},"
        "format=yuv420p"
    )

    run(
        [
            "ffmpeg",
            "-y",
            "-framerate",
            str(FPS),
            "-loop",
            "1",
            "-i",
            str(image_path),
            "-t",
            f"{duration:.3f}",
            "-vf",
            vf,
            "-r",
            str(FPS),
            "-an",
            "-c:v",
            "libx264",
            "-preset",
            "medium",
            "-crf",
            "18",
            "-pix_fmt",
            "yuv420p",
            str(clip_path),
        ]
    )
    return clip_path


def concat_clips(clips: list[Path], output_path: Path) -> None:
    list_path = TMP_DIR / "concat.txt"
    list_path.write_text(
        "".join(f"file '{clip.as_posix()}'\n" for clip in clips),
        encoding="utf-8",
    )
    run(
        [
            "ffmpeg",
            "-y",
            "-f",
            "concat",
            "-safe",
            "0",
            "-i",
            str(list_path),
            "-c",
            "copy",
            str(output_path),
        ]
    )


def add_audio(video_path: Path, output_path: Path) -> None:
    narration = ASSETS_DIR / "narracao.mp3"
    track = ASSETS_DIR / "trilha.mp3"

    if not narration.exists() and not track.exists():
        print("\nNenhum arquivo de áudio encontrado. Gerando vídeo sem áudio.")
        shutil.copy2(video_path, output_path)
        return

    if narration.exists() and track.exists():
        run(
            [
                "ffmpeg",
                "-y",
                "-i",
                str(video_path),
                "-stream_loop",
                "-1",
                "-i",
                str(track),
                "-i",
                str(narration),
                "-filter_complex",
                "[1:a]volume=0.16[a1];[2:a]volume=1.0[a2];[a1][a2]amix=inputs=2:duration=shortest:dropout_transition=2[a]",
                "-map",
                "0:v:0",
                "-map",
                "[a]",
                "-shortest",
                "-c:v",
                "copy",
                "-c:a",
                "aac",
                "-b:a",
                "192k",
                str(output_path),
            ]
        )
        return

    audio_path = narration if narration.exists() else track
    volume = "1.0" if narration.exists() else "0.18"
    input_args = ["-i", str(audio_path)]
    if track.exists() and not narration.exists():
        input_args = ["-stream_loop", "-1", "-i", str(audio_path)]

    run(
        [
            "ffmpeg",
            "-y",
            "-i",
            str(video_path),
            *input_args,
            "-filter:a",
            f"volume={volume}",
            "-map",
            "0:v:0",
            "-map",
            "1:a:0",
            "-shortest",
            "-c:v",
            "copy",
            "-c:a",
            "aac",
            "-b:a",
            "192k",
            str(output_path),
        ]
    )


def main() -> None:
    require_ffmpeg()
    validate_assets()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    if TMP_DIR.exists():
        shutil.rmtree(TMP_DIR)
    TMP_DIR.mkdir(parents=True)

    print("Gerando cenas...")
    clips = [render_scene(scene, index) for index, scene in enumerate(SCENES, start=1)]

    silent_video = TMP_DIR / "reels_rodizio_homepage_v1_silent.mp4"
    print("\nConcatenando cenas...")
    concat_clips(clips, silent_video)

    print("\nAplicando áudio opcional...")
    add_audio(silent_video, FINAL_VIDEO)

    print()
    print("OK: vídeo V1 gerado em:")
    print(f"  {FINAL_VIDEO}")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        print()
        print("ERRO: FFmpeg falhou ao gerar o vídeo.")
        print(f"Código de saída: {error.returncode}")
        raise SystemExit(error.returncode)

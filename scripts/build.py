"""
Cross-platform build script for AWS Lambda Python services.

Usage:
  python build.py service-a          # Build a single service
  python build.py --all              # Build all services
  python build.py --clean service-a  # Clean build artifacts
"""

import argparse
import logging
import shutil
import subprocess
import sys
from pathlib import Path

# --- Logging setup ---
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)

# --- Paths ---
REPO_ROOT = Path(__file__).parent.parent.resolve()
SERVICES_DIR = REPO_ROOT / "services"
DEFAULT_BUILD_ROOT = REPO_ROOT / "build"


# --- Helper functions ---
def clean(service: Path, build_root: Path = DEFAULT_BUILD_ROOT) -> None:
    """Remove build artifacts for a given service."""
    build_path = build_root / service.name
    if build_path.exists():
        shutil.rmtree(build_path)
        logger.info(f"Removed {build_path}")


def build(service: Path, build_root: Path = DEFAULT_BUILD_ROOT) -> None:
    """Build a Lambda zip package for a given service."""
    logger.info(f"Building service: {service.name}")

    build_path = build_root / service.name
    clean(service, build_root)
    build_path.mkdir(parents=True, exist_ok=True)
    zip_file = build_root / service.name

    # Install package and dependencies
    logger.info(f"Installing package into {build_path}")
    try:
        subprocess.run(
            ["uv", "pip", "install", ".", "--target", str(build_path), "--platform", "manylinux2014_x86_64"],
            cwd=service,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        logger.error(f"Package installation failed for {service.name}")
        sys.exit(e.returncode)

    # Create zip archive
    logger.info(f"Creating zip package {zip_file}.zip")
    shutil.make_archive(str(zip_file), "zip", build_path)
    logger.info(f"Built {zip_file}.zip")


def find_services() -> list[Path]:
    """Find all service directories under SERVICES_DIR."""
    return [p for p in SERVICES_DIR.iterdir() if p.is_dir()]


# --- CLI ---
def main():
    parser = argparse.ArgumentParser(description="Build AWS Lambda services")
    parser.add_argument(
        "services", nargs="*", help="Services to build (by folder name)"
    )
    parser.add_argument("--all", action="store_true", help="Build all services")
    parser.add_argument(
        "--clean", action="store_true", help="Clean build artifacts instead of building"
    )
    parser.add_argument(
        "--build-root",
        default=DEFAULT_BUILD_ROOT,
        help="Root build directory (default: repo_root/build/)",
    )
    parser.add_argument("--debug", action="store_true", help="Enable debug logging")

    args = parser.parse_args()
    if args.debug:
        logger.setLevel(logging.DEBUG)

    available_services = {s.name: s for s in find_services()}

    if args.all:
        targets = available_services.values()
    else:
        if not args.services:
            parser.error("Specify services to build or use --all")
        missing = [s for s in args.services if s not in available_services]
        if missing:
            parser.error(f"Unknown service(s): {', '.join(missing)}")
        targets = [available_services[s] for s in args.services]

    for service in targets:
        if args.clean:
            clean(service, Path(args.build_root))
        else:
            build(service, Path(args.build_root))


if __name__ == "__main__":
    main()

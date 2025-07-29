import os
import shutil
import tempfile
import zipfile
from pathlib import Path

def zip_lambda_source(backend_dir: Path, build_dir: Path, zip_name: str = "deployment-package.zip"):
    zip_path = build_dir / zip_name

    # Ensure build directory exists
    build_dir.mkdir(parents=True, exist_ok=True)

    # Create a temporary directory
    with tempfile.TemporaryDirectory() as temp_dir_str:
        temp_dir = Path(temp_dir_str)

        # Copy all backend files into the temp directory
        for item in backend_dir.iterdir():
            dest = temp_dir / item.name
            if item.is_dir():
                shutil.copytree(item, dest)
            else:
                shutil.copy2(item, dest)

        # Remove existing zip if present
        if zip_path.exists():
            zip_path.unlink()

        # Create a ZIP archive from the temp directory
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for file in temp_dir.rglob("*"):
                zipf.write(file, file.relative_to(temp_dir))

    print(f"✅ Lambda deployment package created at: {zip_path}")

if __name__ == "__main__":
    project_root = Path(__file__).resolve().parent.parent
    backend_dir = project_root / "backend"
    build_dir = project_root / "build"

    zip_lambda_source(backend_dir, build_dir)

import argparse
import datetime
from pathlib import Path
from shutil import copytree, copy2
from typing import Union, Callable
import markdown
import re

build_dir : Path
verbose : bool = False
warnings : int = 0

md_extensions = ["md_in_html"]

def main() -> None:
	print("[Main] ✔️ Starting website generation")
	build_dir.mkdir(parents=True, exist_ok=True)

	copytree("templates/favicons", build_dir, dirs_exist_ok=True)
	copy2("templates/CNAME", build_dir)

	with open(Path("README.md"), "r", encoding="utf-8") as readme_file:
		inp: str = readme_file.read()
		saveHTML(build_dir / "index.html",
			htmlSnippet_head()  # HTML standard head
			+ re.sub(r'<img alt="([^"]*)"', r'<img title="\1" alt="\1"',  # Copy alt text in pins to their hover text
			markdown.markdown(inp, extensions=md_extensions))  # Actually convert the markdown
			.replace("src=\"https://github-readme-stats.vercel.app/api/pin/?username=", "class=\"pin\" src=\"https://github-readme-stats.vercel.app/api/pin/?username=")  # Adds the pin class to GitHub pins
			+ htmlSnippet_footer())  # HTML standard footer

	if warnings == 0:
		print("[Main] ✔️ Finished with no warnings!")
	else:
		print("[Main] ⚠️ Finished with", warnings, "warnings")

def verboseLog(*inp):
	if verbose:
		if len(inp) > 1:
			log : str = ""
			for piece in inp:
				log += piece + " "
			print(log.strip())
		else:
			print(inp[0])

def saveHTML(location : Path, contents : Union[str, Callable[[], str]]) -> None:
	verboseLog(f"[Generation] 🖨️ Saving HTML file: {location.__fspath__()}")
	if callable(contents):
		contents = contents()
	with open(location, "w", encoding="utf-8", errors="xmlcharrefreplace") as output_file:
		output_file.write(contents)

def htmlSnippet_head() -> str:
	with open("templates/head.html") as ioH:
		with open("templates/style.css") as ioC:
			css : str = ioC.read()
			return ioH.read().replace("{{css}}", css)

def htmlSnippet_footer() -> str:
	with open("templates/footer.html") as ioF:
		return ioF.read()\
			.replace("{{year}}", str(datetime.datetime.now().year))\
			.replace("{{date}}", str(datetime.datetime.now(datetime.timezone.utc).astimezone().isoformat(sep=" ", timespec="seconds")))

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="A script to generate TechnicJelle's resume website")
	parser.add_argument("-b", "--build_dir", help="Overrides the directory where the files get generated to", default="build")
	parser.add_argument("-v", "--verbose", help="Prints more information about the things the script is currently doing", action="store_true")
	args = parser.parse_args()
	verbose = args.verbose
	build_dir = Path(args.build_dir)

	main()

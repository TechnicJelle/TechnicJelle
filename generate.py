import argparse
import datetime
from pathlib import Path
from shutil import copytree, copy2
from typing import Union, Callable
import markdown
import re
from ghapi.all import GhApi

build_dir : Path
verbose : bool = False
warnings : int = 0
gh_api: GhApi

md_extensions = ["md_in_html", "tables"]

def main() -> None:
	print("[Main] ✔️ Starting website generation")
	build_dir.mkdir(parents=True, exist_ok=True)

	copytree("templates/favicons", build_dir, dirs_exist_ok=True)
	copy2("templates/CNAME", build_dir)

	saveHTML(build_dir / "index.html",
		htmlSnippet_head()
		+ htmlSnippet_markdown()
		+ htmlSnippet_footer())

	if warnings == 0:
		print("[Main] ✔️ Finished with no warnings!")
	else:
		print("[Main] ⚠️ Finished with", warnings, "warnings")

def verboseLog(*inp) -> None:
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

def htmlSnippet_markdown() -> str:
	with open(Path("README.md"), "r", encoding="utf-8") as readme_file:
		inp: str = readme_file.read()
		mdHTML: str = markdown.markdown(inp, extensions=md_extensions)
		mdHTML = re.sub(r'(?:<p>)?<a.+(https://github.com/.+/.+)">.+img alt="(.+)" src=.+vercel.+/a>(?:</p>)?', htmlSnippet_card, mdHTML)
		return mdHTML

def htmlSnippet_card(match: re.Match) -> str:
	title : str = match.group(2)
	link : str = match.group(1)

	r = gh_api.repos.get(link.split("/")[-2], link.split("/")[-1])
	desc: str = r.description if r.description is not None else "<i>No description</i>"
	lang: str = r.language
	stars: int = r.stargazers_count

	verboseLog(f"[Generation] 🖼️ Making card: {link} {title}")
	with open("templates/card.html") as ioC:
		return ioC.read()\
			.replace("{{title}}", title)\
			.replace("{{link}}", link)\
			.replace("{{language}}", lang)\
			.replace("{{class}}", lang.replace("#", "s").replace("+", "p"))\
			.replace("{{description}}", desc)\
			.replace("{{stars}}", htmlSnippet_stars(stars, link))

def htmlSnippet_stars(stars: int, link: str) -> str:
	if stars == 0:
		return ""
	with open("templates/stars.html") as ioS:
		return ioS.read()\
			.replace("{{link}}", link)\
			.replace("{{stars}}", f"⭐{stars}")

def htmlSnippet_footer() -> str:
	with open("templates/footer.html") as ioF:
		return ioF.read()\
			.replace("{{year}}", str(datetime.datetime.now().year))\
			.replace("{{date}}", str(datetime.datetime.now(datetime.timezone.utc).astimezone().isoformat(sep=" ", timespec="seconds")))

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="A script to generate TechnicJelle's resume website")
	parser.add_argument("-b", "--build_dir", help="Overrides the directory where the files get generated to", default="build")
	parser.add_argument("-v", "--verbose", help="Prints more information about the things the script is currently doing", action="store_true")
	parser.add_argument("-g", "--github", help="Optional GitHub API token", default="")
	args = parser.parse_args()
	verbose = args.verbose
	build_dir = Path(args.build_dir)
	gh_api = GhApi(token=args.github)

	main()

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
			 + htmlSnippet_markdown_start()
			 + htmlSnippet_visual()
			 + htmlSnippet_markdown_main()
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
	verboseLog(f"[Output] 🖨️ Saving HTML file: {location.__fspath__()}")
	if callable(contents):
		contents = contents()
	with open(location, "w", encoding="utf-8", errors="xmlcharrefreplace") as output_file:
		output_file.write(contents)

def convertMarkdown(inp : str) -> str:
	return markdown.markdown(inp, extensions=md_extensions)

def htmlSnippet_head() -> str:
	verboseLog("[HTML] 📄 Getting head")
	with open("templates/head.html") as ioH:
		with open("templates/style.css") as ioC:
			css : str = ioC.read()
			return ioH.read().replace("{{css}}", css)

def getMarkdownRegion(region: str) -> str:
	verboseLog(f"[Markdown] 📃 Getting Markdown region: {region}")
	with open(Path("README.md"), "r", encoding="utf-8") as readme_file:
		inp: str = readme_file.read()
		start: int = re.search(f"<!---\s*region:\s*{region}\s*-->", inp).end()
		endRe = re.search(f"<!---\s*region:\s*", inp[start:])
		end: int = endRe.start() + start if endRe is not None else len(inp)
		return inp[start:end]

def htmlSnippet_markdown_start() -> str:
	verboseLog("[HTML] 📄 Getting Markdown start")
	md: str = getMarkdownRegion("title")
	return convertMarkdown(md)

def htmlSnippet_visual() -> str:
	verboseLog("[HTML] 📄 Getting visual")
	md: str = getMarkdownRegion("visual")
	imgLink: str = re.search(r'src="(.+)" ', md).group(1)
	haiku: str = re.search(r'> \| (.+) \|', md).group(1)
	with open("templates/visual.html") as ioV:
		return ioV.read()\
			.replace("{{image}}", imgLink)\
			.replace("{{haiku}}", haiku)

def htmlSnippet_markdown_main() -> str:
	verboseLog("[HTML] 📄 Getting Markdown main")
	md: str = getMarkdownRegion("intro")\
			  + getMarkdownRegion("connect")\
			  + getMarkdownRegion("experiences")\
			  + getMarkdownRegion("projects")
	mdHTML: str = convertMarkdown(md)
	mdHTML = re.sub(r'(?:<p>)?<a.+(https://github.com/.+/.+)">.+img alt="(.+)" src=.+vercel.+/a>(?:</p>)?', htmlSnippet_card, mdHTML)
	mdHTML = re.sub(r'<h([2-4])>(.+)</h\1>', processHeader, mdHTML)
	return mdHTML

def processHeader(match: re.Match) -> str:
	h: str = match.group(1)
	title: str = match.group(2)
	titleClean: str = re.sub(r'<a href="(.+)">(.+)</a>', r'\2', title) # Remove links from titles
	id: str = titleClean.lower().replace(" ", "-")
	verboseLog(f"[Post-Processing] 📑 Converting header: h{h}  {titleClean} => #{id}")
	result: str = f'<h{h} id="{id}">{title}<a href="#{id}" class="link"> 🔗</a></h{h}>'
	return result

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

import argparse
import datetime
import re
from pathlib import Path
from shutil import copytree
from typing import Union, Callable

import markdown
from ghapi.all import GhApi

build_dir: Path
verbose: bool = False
warnings: int = 0
gh_api: GhApi

md_extensions = ["md_in_html"]

headers: list[(int, str, str)] = []


def main() -> None:
	print("[Main] ✔️ Starting website generation")
	build_dir.mkdir(parents=True, exist_ok=True)

	copytree("copy", build_dir, dirs_exist_ok=True)

	projects: str = convertMarkdown(getMarkdownRegion("projects"))
	projects: str = re.sub(r'(?:<p>)?<a.+(https://github.com/.+/.+)">.+img alt="(.+)" src=.+vercel.+/a>(?:</p>)?', htmlSnippet_cardRepo, projects)
	projects: str = re.sub(r'(?:<p>)?<a.+(https://gist\.github.com/.+/.+)">.+img alt="(.+)" src=.+vercel.+/a>(?:</p>)?', htmlSnippet_cardGist, projects)
	projects: str = re.sub(r'(\s*<h([23])>.*</h\2>)', r'\n</div>\1<div class="two-col">', projects)  # Remove the first ending div that was added by the previous regex
	projects: str = "\n" + re.sub(r'^\s*</div.*?>', "", projects) + "</div>\n\n"  # Close the last div

	print(projects)

	html: str = htmlSnippet_head()\
		+ convertMarkdown(getMarkdownRegion("title"))\
		+ htmlSnippet_visual()\
		+ convertMarkdown(getMarkdownRegion("intro"))\
		+ convertMarkdown(getMarkdownRegion("connect"))\
		+ convertMarkdown(getMarkdownRegion("experiences"))\
		+ projects\
		+ htmlSnippet_footer()

	html = linkifyHeaders(html)

	html = re.sub(r'(<!---\s*{{toc}}\s*-->)', generateTOC(), html)

	saveHTML(build_dir / "index.html", html)

	if warnings == 0:
		print("[Main] ✔️ Finished with no warnings!")
	else:
		print("[Main] ⚠️ Finished with", warnings, "warnings")


def verboseLog(*inp) -> None:
	if verbose:
		if len(inp) > 1:
			log: str = ""
			for piece in inp:
				log += piece + " "
			print(log.strip())
		else:
			print(inp[0])


def saveHTML(location: Path, contents: Union[str, Callable[[], str]]) -> None:
	verboseLog(f"[Output] 🖨️ Saving HTML file: {location.__fspath__()}")
	if callable(contents):
		contents = contents()
	with open(location, "w", encoding="utf-8", errors="xmlcharrefreplace") as output_file:
		output_file.write(contents)


def convertMarkdown(inp: str) -> str:
	return markdown.markdown(inp, extensions=md_extensions)


def htmlSnippet_head() -> str:
	verboseLog("[HTML] 📄 Getting head")
	with open("templates/head.html") as ioH:
		with open("templates/style.css") as ioC:
			css: str = ioC.read()
			return ioH.read().replace("{{css}}", css)


def langToCSSClass(lang: str) -> str:
	return lang.replace("#", "s").replace("+", "p")


def getMarkdownRegion(region: str) -> str:
	verboseLog(f"[Markdown] 📃 Getting Markdown region: {region}")
	with open(Path("README.md"), "r", encoding="utf-8") as ioR:
		inp: str = ioR.read()
		start: int = re.search(rf"<!---\s*region:\s*{region}\s*-->", inp).end()
		endRe = re.search(rf"<!---\s*region:\s*", inp[start:])
		end: int = endRe.start() + start if endRe is not None else len(inp)
		return inp[start:end]


def htmlSnippet_visual() -> str:
	verboseLog("[HTML] 📄 Getting visual")
	md: str = getMarkdownRegion("visual")
	imgLink: str = re.search(r'src="(.+)" ', md).group(1)
	haiku: str = re.search(r'> \| (.+) \|', md).group(1)
	with open("templates/visual.html") as ioV:
		return ioV.read()\
			.replace("{{image}}", imgLink)\
			.replace("{{haiku}}", haiku)


def htmlSnippet_cardRepo(match: re.Match) -> str:
	link: str = match.group(1)
	link: str = link.rstrip("/")  # Remove potential trailing slash
	title: str = match.group(2)
	owner: str = link.split("/")[-2]
	repoName: str = link.split("/")[-1]

	r = gh_api.repos.get(owner, repoName)
	desc: str = r.description if r.description is not None else "<i>No description</i>"
	lang: str|None = r.language
	if lang == "ShaderLab": lang = "C#"
	stars: int = r.stargazers_count

	verboseLog(f"[Generation] 🖼️ Making card for repo: {link} {title}")
	with open("templates/card.html") as ioC:
		result = ioC.read()\
			.replace("{{title}}", title)\
			.replace("{{link}}", link)\
			.replace("{{description}}", desc)\
			.replace("{{stars}}", htmlSnippet_stars(stars, link))
		if lang is None:
			result = result \
				.replace("{{language}}", "n/a") \
				.replace("{{class}}", "None")
		else:
			result = result \
				.replace("{{language}}", lang) \
				.replace("{{class}}", langToCSSClass(lang))
		return re.sub(r'\n\s*\n', '\n', result)  # Remove empty lines


def htmlSnippet_cardGist(match: re.Match) -> str:
	link: str = match.group(1)
	link: str = link.rstrip("/")  # Remove potential trailing slash
	gist_id: str = link.split("/")[-1]
	title: str = match.group(2)

	g = gh_api.gists.get(gist_id)
	desc: str = g.description if g.description is not None else "<i>No description</i>"

	files = g.files
	# Count all languages in gist
	langs: dict[str, int] = {}
	for file in files.values():
		lang: str = file.language
		if lang in langs:
			langs[lang] += 1
		else:
			langs[lang] = 1

	# Get most common language
	lang: str = max(langs, key=langs.get)

	verboseLog(f"[Generation] 🖼️ Making card for gist: {link} {title}")
	with open("templates/card.html") as ioC:
		return ioC.read()\
			.replace("{{title}}", title)\
			.replace("{{link}}", link)\
			.replace("{{language}}", lang)\
			.replace("{{class}}", langToCSSClass(lang))\
			.replace("{{description}}", desc)\
			.replace("{{stars}}", "")


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


def linkifyHeaders(html: str) -> str:
	def processHeader(match: re.Match) -> str:
		h: str = match.group(1)
		title: str = match.group(2)
		titleClean: str = re.sub(r'<a href="(.+)">(.+)</a>', r'\2', title)  # Sanitize links from titles
		legacy_id: str = titleClean.lower().replace(" ", "-")
		id: str = re.sub(r'[^a-z0-9 ]', '', titleClean.lower()).strip().replace(" ", "-")
		if id != legacy_id:
			legacy_tag = f'<span id="{legacy_id}"></span>'
		else:
			legacy_tag = ""  # Don't need to supply a legacy tag if they're the same
		verboseLog(f"[Linkify] 🔗 Converting header: h{h}  {titleClean} => #{id}")
		headers.append((int(h), id, titleClean))  # Save header for TOC
		result: str = f'<h{h} id="{id}">{legacy_tag}{title}<a href="#{id}" class="link"> 🔗</a></h{h}>'
		return result

	verboseLog("[Post-Processing] 📑 Linkifying headers")
	return re.sub(r'<h([2-4])>(.+)</h\1>', processHeader, html)


def generateTOC() -> str:
	verboseLog("[Post-Processing] 📑 Generating table of contents")
	toc: str = "<ul>\n"
	startLevel: int = headers[0][0]
	lastLevel: int = startLevel
	for header in headers:
		level: int = header[0]
		if level > 3:
			continue
		id: str = header[1]
		title: str = header[2]
		if level > lastLevel:
			toc += "<li>\n<ul>\n"
		if level < lastLevel:
			toc += "</ul>\n</li>\n"
		lastLevel = level
		with open("templates/toc-item.html") as ioT:
			toc += ioT.read()\
				.replace("{{link}}", id)\
				.replace("{{title}}", title)

	for i in range(lastLevel - startLevel):
		toc += "</ul>\n</li>\n"

	toc += "</ul>\n"
	with open("templates/toc.html") as ioT:
		return ioT.read().replace("{{toc}}", toc)


if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="A script to generate TechnicJelle's portfolio website")
	parser.add_argument("-b", "--build_dir", help="Overrides the directory where the files get generated to", default="build")
	parser.add_argument("-v", "--verbose", help="Prints more information about the things the script is currently doing", action="store_true")
	parser.add_argument("-g", "--github", help="Optional GitHub API token", default="")
	args = parser.parse_args()
	verbose = args.verbose
	build_dir = Path(args.build_dir)
	gh_api = GhApi(token=args.github)

	main()

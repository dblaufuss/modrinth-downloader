import requests
import json
from bs4 import BeautifulSoup

# PARAMETERS
collection_id = "j1vbZc9Y"
game_version =  "1.21.11"
loader_api = "fabric"


collection_data = requests.get(f"https://modrinth.com/collection/{collection_id}")
soup = BeautifulSoup(collection_data.text, "html.parser")

mod_ids = set()
for link in soup.find_all("a"):
    if "/mod/" in link.get("href"):
        mod_ids.add(link.get("href").split("/")[-1])

print(mod_ids)
print("\n")

download_urls = []

for mod in mod_ids:
    print("mod_id: " + mod)

    compatible = False

    version_data = requests.get(f"https://api.modrinth.com/v2/project/{mod}/version")
    version_json = json.loads(version_data.content)

    for version in version_json:
        if loader_api not in version["loaders"]:
            continue

        if game_version in version["game_versions"]:

            print("version_name: " + version["name"])
            print("version_number: " + version["version_number"])
            print("date_published: " + version["date_published"])

            download_urls.append(version["files"][0]["url"])
            compatible = True

            break
    
    if compatible == False:
        print("WARNING: No compatible version found!")
    
    print("\n\n")
    
with open("urls.txt", "w+") as f:
    f.write("\n".join(download_urls))
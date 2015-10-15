import os.path
import requests

urls = []
names = []

def download_archive(url, local_filename):
    if os.path.isfile(local_filename):
        print "reusing",local_filename,"for",url
        return 
    r = requests.get(url, stream=True)
    if (r.status_code != 200):
        print r.status_code, url
        url = "https://www.bioconductor.org/packages/release/bioc/src/contrib/" + local_filename
        r = requests.get(url, stream=True)
    if (r.status_code != 200):
        print r.status_code, url
        url = "http://bioconductor.org/packages/release/data/annotation/src/contrib/" + local_filename
        r = requests.get(url, stream=True)
    if (r.status_code != 200):
        print r.status_code, url
        print "Giving up can not find!"
        exit(-1)
    print local_filename,"coping from",url         
    with open(local_filename, 'wb') as f:
        for chunk in r.iter_content(chunk_size=1024): 
            if chunk: # filter out keep-alive new chunks
                f.write(chunk)
                f.flush()

def process_url(url):
    local_filename = url.split('/')[-1]
    name = local_filename[:local_filename.find("_")]
    if name in names:
        print "repeat", name
    else:
        download_archive(url, local_filename)
        github = "https://github.com/Christian-B/galaxy_shedtools/raw/master/r_extended/" + local_filename  # ?raw=true
        urls.append(github)
        names.append(name)

def process_line(line):
    if len(line) < 10:
        return
    end = line.find("</package")
    if line.startswith("<package>"):
        url = line[9:end]
    elif line.startswith("<!--package>"):
        url = line[12:end]
    else:
        print "opps", line
        return
    process_url(url)

if __name__ == '__main__':
    file_name = "package_list.txt"
    with open(file_name, 'r') as f:
        for line in f:        
            process_line(line)

    PACKAGE_XML_TEMPLATE = "                    <package>%s</package>\n"
    with open("short_package_list.txt", 'w') as f:
        for url in urls:
            f.write(PACKAGE_XML_TEMPLATE % url )

    LIBRARY_TEMPLATE = "library(%s)\n"
    with open("packages.R", 'w') as f:
        for name in names:
            f.write(LIBRARY_TEMPLATE % name )
        f.write("\nargs<-commandArgs(TRUE)\n")
        f.write("writeLines(capture.output(sessionInfo()), args[1])\n")
        f.write("sessionInfo()\n")

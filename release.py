#! /usr/bin/env python

import re
import subprocess
import sys


# Check if the new tag we want to create exists already or not
def checkExistingTag(version):
    if (subprocess.call(('git show-ref --verify --quiet refs/heads/%s' % version).split()) == 0 or
            subprocess.call(('git show-ref --verify --quiet refs/tags/%s' % version).split()) == 0):
        print "Error: The tag '%s' already exists" % version
        raise Exception()


# Remove /dist from the .gitignore for the releases
def updateGitignore():
    file_str = None
    with open('.gitignore') as f:
        file_str = f.read()

    file_str = re.sub(r'/dist', '', file_str)

    with open('.gitignore', "w") as f:
        f.write(file_str)


# Commit the changes (/dist, .gitignore, /demo) and push the new tag
def commit(version):
    untrackedFiles = subprocess.Popen('git ls-files -o --exclude-standard'.split(), stdout=subprocess.PIPE)
    subprocess.call(('git add %s' % untrackedFiles.stdout.read().replace('\n', ' ')).split())
    subprocess.call(['git', 'commit', '-am', 'chore release: new release %s' % version], stderr=subprocess.STDOUT,
                    stdout=subprocess.PIPE)
    subprocess.call(('git tag %s' % version).split())

    print "Publishing new tag"
    subprocess.call(('git push origin %s' % version).split(), stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
    print "Release %s created!" % version


if __name__ == "__main__":
    try:
        if len(sys.argv) == 1:
            print "Error: The version name is required"
            raise Exception()

        version = sys.argv[1]

        checkExistingTag(version)
        updateGitignore()
        commit(version)
    except Exception as e:
        exit(-1)

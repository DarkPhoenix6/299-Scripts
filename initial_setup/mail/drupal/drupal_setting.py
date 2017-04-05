#!/usr/bin/python
import re
import sys
# passed in parameters
domainName=sys.argv[1]
file=sys.argv[2]


def to_File():
	f = open('%s' % (file), 'a')
	p1,p2 = domainName.split(".")
	f.writelines(["$settings['trusted_host_patterns'] = array(\n", "  \'^%s\.%s$\',\n" % (p1,p2), "  '^www\.%s\.%s$',\n" % (p1,p2),"  '^mail\.%s\.%s$',\n" % (p1,p2), ");\n", "if (file_exists(__DIR__ . '/settings.local.php')) {\n", "  include __DIR__ . '/settings.local.php';\n", "}\n"])
	f.close()


def main():
	to_File()

if __name__ == '__main__':		
	main()

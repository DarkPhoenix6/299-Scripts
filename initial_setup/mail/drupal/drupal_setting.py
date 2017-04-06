#!/usr/bin/python
#
######################################################################
#
#	Name:		 	drupal_setting.py
#	Author:			Chris Fedun 04/04/2017
#	Description:	Drupal Setup Python script 
#	Copyright (C) 2017  Christopher Fedun
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
######################################################################
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

####### END :) #######
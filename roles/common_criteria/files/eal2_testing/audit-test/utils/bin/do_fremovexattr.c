/*  (c) Copyright Hewlett-Packard Development Company, L.P., 2007
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of version 2 the GNU General Public License as
 *  published by the Free Software Foundation.
 *  
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "includes.h"
#include <sys/xattr.h>

int main(int argc, char **argv)
{
    int exitval, result;
    int fd;

    if (argc != 3) {
	fprintf(stderr, "Usage:\n%s <path> <xattr name>\n",
		argv[0]);
	return 1;
    }

    fd = open(argv[1], O_RDONLY); 
    if (fd == -1) {
	perror("do_fremovexattr: open fd");
	return TEST_ERROR;
    }

    errno = 0;
    exitval = fremovexattr(fd, argv[2]);
    result = exitval < 0;

    fprintf(stderr, "%d %d %d\n", result, result ? errno : exitval, getpid());
    return result;
}

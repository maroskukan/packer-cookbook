#!/usr/bin/env python

# The following script generates password hash for root user that can be used in Kickstart file

import crypt

print(crypt.crypt(input('clear-text-pw: '), crypt.mksalt(crypt.METHOD_SHA512)))
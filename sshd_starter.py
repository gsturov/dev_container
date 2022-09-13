#!/usr/bin/python3
import os

skip = ['SHELL', 'SSH_AUTH_SOCK', 'PWD', 'LOGNAME', 'TZ', 'MOTD_SHOWN', 'HOME', 'LS_COLORS', 'SSH_CONNECTION', 'LESSCLOSE', 'TERM', 'LESSOPEN', 'USER', 'SHLVL', 'SSH_CLIENT', 'PATH', 'SSH_TTY', '_']

command = "/usr/sbin/sshd -d -o 'SetEnv="
for key in os.environ:
    if key in skip: continue
    value = os.environ[key]
    command += f'{key}="{value}" '

command += "'"
print(command)

while True:
    os.system(command)
    print('sshd exited.')
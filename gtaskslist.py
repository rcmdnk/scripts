#! /usr/bin/env python

import os
import sys
import httplib2

from oauth2client.file import Storage
from oauth2client.tools import run
from oauth2client.client import OAuth2WebServerFlow
from apiclient.discovery import build

def main(uselist='',items=''):
    # Authentaation
    storage = Storage(os.path.expanduser('~/.gtaskslist.dat'))
    credentials = storage.get()

    if credentials is None or credentials.invalid:
        credentials = run(
          OAuth2WebServerFlow(
            client_id='326384869607.apps.googleusercontent.com',
            client_secret='hm4nOe7yiMvpip0qE5s7D-AS',
            scope=[
              'https://www.googleapis.com/auth/tasks',
              'https://www.googleapis.com/auth/tasks.readonly'],
            user_agent='gtaskslist/1.0',),
          storage)

    http = httplib2.Http()
    http = credentials.authorize(http)

    service = build('tasks', 'v1', http=http)

    # Get task lists
    tasklists = service.tasklists().list().execute()
    for tl in tasklists['items']:
        # Check list name
        if uselist != '' and tl['title'] != uselist:
            continue

        # Get tasks
        tasks = service.tasks().list(tasklist=tl['id']).execute()
        for t in tasks['items']:
            ttitle = t['title']
            if ttitle == '':
                continue
            useflag=0
            if len(items) == 0 or items[0] == '':
                useflag = 1
            else:
                for i in items:
                    if ttitle.find(i):
                        useflag = 1
                        break
            if useflag == 1:
                print ttitle.encode('utf_8')
                print t

if __name__ == '__main__':
    # Get command line options
    from optparse import OptionParser
    usage = '''usage: %prog [-opts] arg1 arg2

       If arg1 arg2... are given, only tasks which include
       these words (ORed) will be listed (combined with -i)
       '''
    parser = OptionParser(usage)
    parser.add_option('-l','--list',action='store',
                        dest='uselist',default='',
                        help='If \'USELIST\' is not an empty, tasks will be searched for only from the given list. [default: %default]')
    parser.add_option('-i','--item',action='store',
                        dest='item',default='',
                        help='If \'ITEM\' is not an empty, only tasks which contains given item are listed up. Multiple words can be given by using \',\' as a separator. [default: %default]')
    (opts, args) = parser.parse_args()

    # Set parameters
    uselist = opts.uselist
    items = opts.item.split(',')
    for i in args:
        items.append(i)

    # Run main function
    main(uselist,items)


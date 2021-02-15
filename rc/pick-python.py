#!/usr/bin/python
"""
   find python tags via xpath to ast tree
"""
import ast
import os
import sys
from argparse import ArgumentParser

import astpath

XPATH = {

    'tags': './/*[self::ClassDef or self::FunctionDef or self::AsyncFunctionDef]',
    'routes': ".//*[self::FunctionDef or self::AsyncFunctionDef][ \
        ./decorator_list/Call/func/*[@id = 'route' or @attr = 'route'] \
    ]",
    'tests': './/*[self::FunctionDef or self::AsyncFunctionDef][starts-with(@name, "test_")]',
    'fixtures':  ".//FunctionDef/*[ \
        self::decorator_list/Call/func/Attribute[@attr='fixture'] or \
        self::decorator_list/Call/func/Attribute[@attr='yield_fixture'] or \
        self::decorator_list/Attribute[@attr='fixture'] or \
        self::decorator_list/Attribute[@attr='yield_fixture'] \
     ]"
}


def command_inspect(args):
    filename = args.filename
    if not filename or not os.path.exists(filename):
        raise FileNotFoundError(filename)
    with open(filename, 'rt') as stream:
        source = stream.read()
    parsed = ast.parse(source, filename)
    dump = ast.dump(parsed, indent=4)
    print(dump)


def command_grep(args):
    recurse = not(args.filename and os.path.isfile(args.filename))
    xpath = XPATH[args.target]
    astpath.search(directory=args.filename or '.',
                   expression=xpath, recurse=recurse, print_matches=True)


def command_xpath(args):
    recurse = not(args.filename and os.path.isfile(args.filename))
    astpath.search(directory=args.filename or '.',
                   expression=args.xpath, recurse=recurse, print_matches=True)


def create_parser() -> ArgumentParser:
    parser = ArgumentParser()
    sub = parser.add_subparsers()

    inspect_command = sub.add_parser('inspect', help='print ast')
    inspect_command.add_argument("filename")
    inspect_command.set_defaults(func=command_inspect)

    grep_command = sub.add_parser('grep', help='print predefined xpath')
    grep_command.add_argument("target", choices=XPATH.keys())
    grep_command.add_argument("filename", nargs='?')
    grep_command.set_defaults(func=command_grep)

    xpath_command = sub.add_parser('xpath', help='')
    xpath_command.add_argument("xpath")
    xpath_command.add_argument("filename", nargs='?')
    xpath_command.set_defaults(func=command_xpath)

    return parser


if __name__ == '__main__':
    parser = create_parser()
    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        func = args.func
        sys.exit(func(args))

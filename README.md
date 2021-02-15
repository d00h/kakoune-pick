# Description

plugin for [Kakoune editor](https://kakoune.org/) 
quick pick

* file
* kakoune session
* python class
* python function
* python function with decorator @route
* python function with decorator @fixture
* python function with name like test_

![PickFileExample](https://raw.githubusercontent.com/d00h/kakoune-pick/master/docs/pick-file-example.gif)

# Install

add to kakrc

```shell
plug "d00h/kakoune-pick" config %{
    require-module pick-file
    require-module pick-kakoune
    require-module pick-python

#   alias global ls pick-file
#   alias global sessions pick-kakoune

#   alias global tags     pick-python-tags
#   alias global tests    pick-python-tests
#   alias global routes   pick-python-routes
#   alias global fixture  pick-python-fixtures

}
```

# Requirements

* [FzF is a general-purpose command-line fuzzy finder](https://github.com/junegunn/fzf)
* [fd is a program to find entries in your filesytem](https://github.com/sharkdp/fd)

for module pick-python

* [AstPath - A query language for Python abstract syntax trees](https://github.com/hchasestevens/astpath) 


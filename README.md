# Description

plugins for [Kakoune editor](https://kakoune.org/) 

quick pick

* file
* kakoune session
* python class
* python function
* python function with decorator @route
* python function with decorator @fixture
* python function with name like test_
* 
# Commands

* file-browser

![FileBrowserExample](https://raw.githubusercontent.com/d00h/kakoune-pick/master/docs/file-browser-example.gif)

* find-file 

![FindFileExample](https://raw.githubusercontent.com/d00h/kakoune-pick/master/docs/find-file-example.gif)

* find-buffer
 
# Install

add to kakrc

```shell
plug "d00h/kakoune-pick" config %{

    require-module dh-file-browser # add command file-browser
    require-module dh-find-buffer  # add command find-buffer
    require-module dh-find-file    # add command find-file
    
    alias global find find-file
    map global normal <F2> ": find-buffer<ret>"
    map global normal <F3> ": file-browser<ret>"

}
```

# Requirements

* [FzF is a general-purpose command-line fuzzy finder](https://github.com/junegunn/fzf)
* [fd is a program to find entries in your filesytem](https://github.com/sharkdp/fd)

for module pick-python

* [AstPath - A query language for Python abstract syntax trees](https://github.com/hchasestevens/astpath) 


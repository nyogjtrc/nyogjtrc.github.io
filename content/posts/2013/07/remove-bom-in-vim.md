---
title: 'remove BOM character using vim'
date: 2013-07-14T09:34:00+08:00
tags: [vim, bom]
---
there is an easy way to remove BOM using vim.

just type below commend in vim to remove BOM.

```vim
:set nobomb
:w
```
## check BOM using vim

```vim
:set bomb?
```

## Reference

- [How do I remove the BOM character from my xml file](http://stackoverflow.com/questions/295472/how-do-i-remove-the-bom-character-from-my-xml-file)


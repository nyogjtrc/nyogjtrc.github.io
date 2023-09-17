---
title: "使用 Cobra 製作有多層指令的應用程式 (Nested Subcommands)"
date: 2023-09-17T19:45:20+08:00
tags: [go]
---
Cobra 是一個很方便 cli 函式庫，有許多的 project 都是用他來寫 cli 應用程式，我自己也是很常使用的。

不同於 kubectl, hugo 這類的專案，自己寫的 cli 應用程式，常常會混著主要的應用場景指令、工具型指令或是更臨時的暫時性工具指令。當指令一多時，不免會覺得檔案過多過亂。

因此我就想到何不把一些不常用的工具型指令往更裡面收納一層，這樣不管是在使用 cli 還是在維護程式時，都會比較清爽。

## 多層指令

以下是我想要製作指令的樣子，`tools` 指令裡面再放一層指令 `monitor`
```
app version
app web
app tools monitor
```

實作的方法其實很簡單，只要使用 `AddCommand()` 就可以達到我們的目的。

將 tools 指令加到 root
```go
	rootCmd.AddCommand(tools.ToolsCmd)
```

將 monitor 指令加到 tools
```go
	ToolsCmd.AddCommand(monitorCmd)
```

## 完成的程式碼檔案結構

檔案結構
```
├── cmd
│   ├── root.go
│   ├── tools
│   │   ├── monitor.go
│   │   └── tools.go
│   ├── version.go
│   └── web.go
└── main.go
```

`main.go`
- call `Execute()`
```go
func main() {
	cmd.Execute()
}
```

`cmd/root.go`
- 定義 `rootCmd`
- 將 `ToolsCmd` 加到 `rootCmd`
```go
package cmd

import (
	"os"

	"github.com/nyogjtrc/practice-go/nested-subcommands/cmd/tools"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "app",
	Short: "A nested subcommands app",
	Long:  `A nested subcommands app`,
}

func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	rootCmd.AddCommand(tools.ToolsCmd)
}
```

`cmd/tools/tools.go`
- 定義 `ToolsCmd`，要設定成 Public
```go
package tools

import (
	"github.com/spf13/cobra"
)

// ToolsCmd is a collection of tool commands
var ToolsCmd = &cobra.Command{
	Use:   "tools",
	Short: "a collection of tool commands",
	Long:  `a collection of tool commands`,
}
```

`cmd/tools/monitor.go`
- 定義 `monitorCmd`
- 將 `monitorCmd` 加到 `ToolsCmd`
```go
package tools

import (
	"fmt"

	"github.com/spf13/cobra"
)

var monitorCmd = &cobra.Command{
	Use:   "monitor",
	Short: "tool: monitor command",
	Long:  `tool: monitor command`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("monitor called")
	},
}

func init() {
	ToolsCmd.AddCommand(monitorCmd)
}
```

source code: https://github.com/nyogjtrc/practice-go/tree/main/nested-subcommands

## Reference
- https://github.com/spf13/cobra
- https://github.com/spf13/cobra/blob/main/site/content/user_guide.md#organizing-subcommands

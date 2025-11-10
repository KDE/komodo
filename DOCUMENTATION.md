<!--
SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# KomoDo and Todo.txt

[todo.txt](http://todotxt.org/) is a really simple task management
method, that follows strict but small set of rules.

The first and most important rule of todo.txt is: A single line in your
todo.txt text file represents a single task.

KomoDo parses those lines from your todo.txt file, and showcases them as
their own cards. It aims to show you all the information about your
tasks.

# Basic Syntax

Here is a task with all the items. Items are divided by space and
symbols. The items must always be in this order.

## Task Creation

During task creation, syntax will be something like this:

```todo
(A) 2024-10-23 Do this task for +KomoDoApp @Akademy due:2025-12-10 link:https://kde.org
```

Here is the explanation for the items:

| Item                                   | Description |
|----------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| (A)                                    | Priority of the item, from A to Z. Optional. Will be removed and turned into pri:A when task is completed.|
| 2024-10-23                             | Creation date. Optional, but recommended.|
| Do this task for +KomoDoApp @Akademy   | The description of the task. Projects and contexts can be marked anywhere within the description.|
| +project                               | Items starting with + are projects: What project is this task related to? For example: +Application, +Linux. Optional.|
| @context                               | Items starting with @ are contexts: In what context (place, situation) should this task be worked with? For example: @Home, @Work, @Cafe. Optional.|
| key:value                              | Key:Value pairs that will be parsed by KomoDo. Can be used for links, such as link:https://kde.org. Optional.|
| due:2025-12-10                         | Special Key:Value pair that KomoDo parses as a due date for the task. It only supports date, not time. Optional.|

### Task Completion

When task is marked as completed, KomoDo will format the task like this:

```todo
x 2025-12-30 2024-10-23 Do this task for +KomoDoApp @Akademy due:2025-12-10 link:https://kde.org pri:A
```

Most items stay the same, but there are couple changes:

| Item       | Description |
|------------|-------------------------------------------------------------------------------------------------------------|
| x          |  This marks the completion. If there is no x, task is incomplete. Must be lowercase.|
| 2025-12-30 |  First date is completion date, but only if the task is marked as completed. Optional, but recommended.|
| 2024-10-23 |  Second date is the creation date. Must be specified if the completion date is!|
| pri:A      |  Priorities of completed tasks will be removed from start and appended into the end of task as pri:Priority.|

# What KomoDo does

You should not need to worry much about the syntax, except when creating
tasks. KomoDo will try to take care of the rest for you, such as
updating the completion dates.

You can add as much or as little detail to your tasks, and KomoDo will
do it's best to visualize it for you. KomoDo also has filtering tools
for searching tasks.

You can then also open this same file in any text editor or other
todo.txt applications.

Please see the following link for for more information and the official
todo.txt specification: [Syntax Source Material](https://github.com/todotxt/todo.txt/blob/master/README.md)

# Credits and License 
- Documentation Copyright © Akseli Lahtinen <akselmo@akselmo.dev>
- License: CC-BY-SA-4.0


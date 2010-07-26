Git Workflow Tools
==================
These are a set of [git](http://git-scm.org/) extensions to integrate with [Pivotal Tracker](http://www.pivotaltracker.com/).

* `git workflow-setup` configures your environment appropriately
* `git start` starts a new branch with an associated PT story
* `git finish` finishes the current, or given, branch and associated PT story

Usage
-----
First you run `git workflow-setup` and follow the instructions.

If you want to start a PT story all you need to do is:

  `git start NNNNNN`

Where `NNNNNN` is the PT story number.

When you have finished it your can either do:

  `git finish`

If you're on a branch you want to mark as finished, or:

  `git finish NNNNNN`

To finish the story `NNNNNN`.

Settings
--------
They require certain git configuration settings, either globally or on the project:

* `user.name`                       your name as it appears on PT
* `pt.username`                     your name as it appears on PT (only required if `user.name` is not correct)
* `pt.token`                        your PT API token (find it on your [PT Profile](https://www.pivotaltracker.com/profile) page)
* `pt.projectid`                    the PT ID for your project (the number from the PT URL)
* `workflow.localbranchconvention`  used to generate the name of the local branch
* `workflow.remotebranchconvention` used to generate the name of the remote branch
* `workflow.callbacks`              the style of interaction you have with git

You are *strongly* advised to use `git workflow-setup` to configure these settings.

Obviously these settings can be set globally (`user.name`, `pt.username` and `pt.token` are good candidates for this) or at the individual git repository level.  It is highly recommended that `pt.projectid` be set on a per-project basis, obviously.  Remember that if these are set in the project then they override the global settings, which can be useful if you work with several different PT accounts across several different projects.

Callbacks/Hooks
---------------
The behaviour of what happens when you issue `git start` or `git finish` is driven by hooks.  At the moment there a couple of forms of hooks included in the code:

* `default`     creates a branch or merges a branch
* `debug`       built on top of `default`, this simply adds more debugging output
* `mine`        performs the steps I use for this (and other) projects
* `sanger`      performs the steps used by Production Software at [The Wellcome Trust Sanger Institute](http://www.sanger.ac.uk/)

The workflow for `sanger` is easy to describe:

* `git start`   creates a branch from the head of master and marks the PT story started
* `git finish`  runs `rake test features` and the pushes the branch to the remote repository

My workflow, used by `mine`, is a little more complex:

* `git start`   creates a branch from the head of master and marks the PT story started
* `git finish`  runs `rake spec features`, merges the branch into master, runs `rake spec features`, then pushes master to the remote repository

Should the `rake` steps fail for either of these workflows then the subsequent steps are not performed, i.e. the branch won't be pushed for `git finish` if `sanger` is being used.

Branch conventions
------------------
The idea for `workflow.localbranchconvention` and `workflow.remotebranchconvention` is that you can have your personal preference for naming branches in your local repository, and a common format for the branch names in the remote repository.  For instance, I might have story ID followed by title as a local convention, you might have the reverse, and the remote repository might have a completely different convention.

The two branch convention settings are freeform text with substitutions.  Values that can be substituted are:

* `story.story_id` is the PT story ID for the story
* `story.name`     is the name of the PT story

For instance, "`${story.id}_${story.name}`" will generate a branch of the form `12345_some_new_feature`, if this is for story 12345 and that story has the name 'Some new feature'.  The final branch will have non-alphanumeric characters replaced by underscore.

*WARNING:* I've not properly tested this with other information being placed inside the convention settings, so you're on your own if you try something different!  The `git workflow-setup` command will only choose between the two possible combinations.

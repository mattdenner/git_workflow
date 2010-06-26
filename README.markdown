Git Workflow Tools
==================
These are a set of [git](http://git-scm.org/) extensions to integrate with [Pivotal Tracker](http://www.pivotaltracker.com/).

* `git start`   starts a new branch with an associated PT story
* `git finish`  finishes the current, or given, branch and associated PT story
* `git release` performs the steps necessary for creating a release

They require certain git configuration settings, either globally or on the project:

* `user.email`                      your email address, and assumed to be your PT login
* `pt.login`                        your PT login, only required if `user.email` is not your PT login
* `pt.token`                        your PT API token
* `pt.projectid`                    the PT ID for your project
* `workflow.localbranchconvention`  used to generate the name of the local branch
* `workflow.remotebranchconvention` used to generate the name of the remote branch

The two branch convention settings are freeform text with substitutions, following the standard Ruby string substitution.  Values that can be substituted are:

* `project`     contains the details of the PT project
* `story`       contains the details of the PT story

For instance, "`#{story.id}_#{story.name}`" will generate a branch of the form `12345_some_new_feature`, if this is for story 12345 and that story has the name 'Some new feature'.  The final branch will have non-alphanumeric characters replaced by underscore.

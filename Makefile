# ATTENTION For advanced `git` users only!
#
# This script will move just cloned `master` branch to `master` subdir
# and will clone all remote branches into corresponding directories
# at the same as this level.
#
_is_git_repo=$(wildcard .git)

ifeq ($(_is_git_repo),)
$(error This Makefile should be in a root of git repository)
endif

workdir_name=$(notdir $(shell pwd))
root_files=README.md Makefile .git

help:
	@echo 'Use `make expand` to get all remote branches as filesystem hierarchy'
	@echo 'Use `make unexpand` to collapse expanded branches'
	@echo 'Use `make add-branch name=<name>` to add a new branch'
	@echo 'Use `make update` to update the expanded tree with not yet expanded branches'

ifeq ($(workdir_name), master)

expand:
	@echo "make[$(MAKELEVEL)]: *** error: the working copy is already expanded into a parent directory!"

unexpand:
	$(fn.branches) | while read dir; do \
		echo "Removing $${dir}"; \
		rm -rf ../"$${dir}"; \
	done; \
	git worktree prune; \
	mv $(root_files) ..; \
	cd ..; \
	pwd; \
	rm -vrf master

add-branch:
ifndef name
	$(error please provide a branch name!)
endif
	git checkout --orphan '$(name)' $$(git rev-list --max-parents=0 HEAD)
	git rm -rf .
	echo 'Started a new branch $(name)' > README.md
	git add README.md
	git commit -am 'Started a new branch $(name)'
	git checkout master
	git worktree add "../$(name)" "$(name)"

for-each-working-tree:
ifndef exec
	$(error please provide a command to execute via `exec` variable!)
endif
	$(fn.branches) | while read dir; do \
		if [[ -d "../$${dir}" $(call fn.make_match_expr,$(match))]]; then \
			cd ../$${dir} && $(exec) && cd - >/dev/null; \
		fi \
	done

update:
	git worktree prune
	$(fn.branches) | while read dir; do \
		if [ ! -d "../$${dir}" ]; then \
			git worktree add --force --checkout ../"$${dir}" "origin/$${dir}"; \
		fi \
	done

else

expand:
	mkdir -p master; \
	mv $(root_files) master; \
	cd master; \
	pwd ; \
	$(fn.branches) | while read dir; do \
		git worktree add --checkout ../"$${dir}" "origin/$${dir}"; \
	done

add-branch unexpand update:
	@echo "make[$(MAKELEVEL)]: *** error: the working copy is not expanded!"

endif

.PHONEY: expand update add-branch for-each-working-tree

# Helper functions to reuse

# Not quite a "function", but a shortcut for shell expression to reuse accross rules...
fn.branches = git branch -a | grep -v master | sed -e 's,\s\+remotes/origin/,,' -e 's,\s\+,,' | sort -u

# Produce bash test expression to check for matching pattern, if argument is given.
# Empty string otherwise.
fn.make_match_expr = $(if $(1),&& "$${dir}" =~ $(match) ,)

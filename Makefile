.DEFAULT_GOAL := build-open-project

# --- VARIABLES ---

PUBSPEC_PATCH = pubspec.yaml
PUBSPEC_VERSION = $(shell awk '/^version:/ {print $$2}' $(PUBSPEC_PATCH) | sed 's/[\r\n"]//g'); \

TEMPLATES_PATH = ~/Library/Application\ Support/Google/AndroidStudio*/fileTemplates

SCRIPT-HEADER-WORKING = "\033[0;33m\n📝"
SCRIPT-HEADER-SUCCESS = "\033[92m\n✅"
SCRIPT-FOOTER = "\n\033[0m"

# --- SCRIPTS ---

build-open-project:
	make build-project
	open -a Android\ Studio .

build-project:
	@echo $(SCRIPT-HEADER-WORKING) "BUILDING PROJECT" $(SCRIPT-FOOTER)
	ssh-add
	git pull
	flutter pub get

finish-version:
	@make build-project || exit 1; \
	make test-project || exit 1; \
	make increase-version || exit 1; \
	make generate-aar || exit 1; \
	make generate-ios-plugins || exit 1; \
	make push-changes || exit 1; \
	make push-tags || exit 1; \

test-project:
	@echo $(SCRIPT-HEADER-WORKING) "TESTING PROJECT" $(SCRIPT-FOOTER)
	flutter test

increase-version:
	@echo $(SCRIPT-HEADER-WORKING) "INCREASING VERSION" $(SCRIPT-FOOTER)
	@echo "Current version:" $(PUBSPEC_VERSION) \
	read -p "Enter new version number: " new_version; \
	sed -i '' "s/^version: .*/version: $$new_version/" $(PUBSPEC_PATCH); \
	echo "Version updated to $$new_version"; \
	export Version=$$new_version

generate-aar:
	@echo $(SCRIPT-HEADER-WORKING) "GENERATING AAR" $(SCRIPT-FOOTER)
	flutter build aar

generate-ios-plugins:
	@echo $(SCRIPT-HEADER-WORKING) "GENERATING IOS PLUGINS" $(SCRIPT-FOOTER)
	@rm -rf .ios
	@flutter create -i swift .
	@cd .ios && pod install > /dev/null 2>&1 || true
	@make replace-flutter-config-path
	@make replace-plugins-dependencies-path
	@mkdir -p .ios/plugins
	@for folder in .ios/.symlinks/plugins/*; do \
		plugin_name=$$(basename "$$folder") && \
		new_folder=".ios/plugins/$$plugin_name" && \
		mkdir -p "$$new_folder" && \
		cp -R "$$folder"/* "$$new_folder" && \
		rm -rf "$$folder"; \
	done

replace-flutter-config-path:
	@cd .ios/Flutter && sed -i.bak 's|FLUTTER_ROOT=.*|FLUTTER_ROOT=~/Documents/Flutter/flutter|; s|FLUTTER_APPLICATION_PATH=.*|FLUTTER_APPLICATION_PATH=../../../t_flutter|' Generated.xcconfig
	@rm -f Generated.xcconfig.bak

replace-plugins-dependencies-path:
	@sed -i.bak 's|\"name\":\"\([^"]*\)\",\"path\":\"[^\"]*\"|\"name\":\"\1\",\"path\":\"../../plugins/\1\"|g' .flutter-plugins-dependencies
	@rm -f .flutter-plugins-dependencies.bak

push-changes:
	@echo $(SCRIPT-HEADER-WORKING) "PUSHING CHANGES" $(SCRIPT-FOOTER)
	git add --all
	@read -p "Enter commit message: " commit_message; \
	git commit -m "$$commit_message"
	git push

push-tags:
	@echo $(SCRIPT-HEADER-WORKING) "PUSHING TAGS" $(SCRIPT-FOOTER)
	git tag $(PUBSPEC_VERSION)
	git push --tags

create-module:
	@echo $(SCRIPT-HEADER-WORKING) "CREATING MODULE" $(SCRIPT-FOOTER)
	@read -p "Module name: ink_" MODULE_NAME; \
	MODULE_NAME="ink_$${MODULE_NAME}"; \
	echo ""; \
	mkdir -p lib/$${MODULE_NAME}; \
	cp -rv $(TEMPLATES_PATH)/Module/* lib/$${MODULE_NAME}; \
	echo "\n$${MODULE_NAME} module created in lib/$${MODULE_NAME}"; \
	echo $(SCRIPT-HEADER-SUCCESS) "MODULE CREATED SUCCESSFUL" $(SCRIPT-FOOTER); \
	echo "Create initial screen?"; \
	select CHOICE in "yes" "no"; do \
		if [ "$$CHOICE" = "yes" ]; then \
			echo ""; \
			read -p "Screen name: " SCREEN_NAME; \
			SCREEN_NAME="$${SCREEN_NAME}"; \
			echo ""; \
			mkdir -p lib/$${MODULE_NAME}/Screens/$${SCREEN_NAME}; \
			cp -rv $(TEMPLATES_PATH)/Screen/* lib/$${MODULE_NAME}/Screens/$${SCREEN_NAME}; \
			find lib/$${MODULE_NAME}/Screens/$${SCREEN_NAME} -type f -name "*FILE_NAME*" -print0 | while read -d $$'\0' FILE; do \
				mv "$$FILE" "$${FILE//FILE_NAME/$${SCREEN_NAME}}"; \
			done; \
			find lib/$${MODULE_NAME}/Module -type f ! -name '.DS_Store' -exec sed -i '' -e "s/\$${INITIAL_SCREEN}/$${SCREEN_NAME}/g" {} \; ; \
			find lib/$${MODULE_NAME}/Screens/$${SCREEN_NAME} -type f ! -name '.DS_Store' -exec sed -i '' -e "s/\$${FILE_NAME}/$${SCREEN_NAME}/g" {} \; ; \
			echo "\n$${SCREEN_NAME} screen created in lib/$${MODULE_NAME}/Screens/$${SCREEN_NAME}"; \
			echo $(SCRIPT-HEADER-SUCCESS) "SCREEN CREATED SUCCESSFUL" $(SCRIPT-FOOTER); \
			break; \
		else \
			echo ""; \
			break; \
		fi; \
	done

create-screen:
	@echo $(SCRIPT-HEADER-WORKING) "CREATING SCREEN" $(SCRIPT-FOOTER)
	@echo "Switch module:"
	@PICKED_MODULE=""
	@MODULES=$$(find lib -type d -name "ink_*" -exec basename {} \;); \
	select MODULE_NAME in $${MODULES}; do \
		if [ -n "$${MODULE_NAME}" ]; then \
			PICKED_MODULE=$${MODULE_NAME}; \
			break; \
		fi; \
	done; \
	echo ""; \
	if [ -n "$${PICKED_MODULE}" ]; then \
		read -p "Screen name: " SCREEN_NAME; \
		SCREEN_NAME="$${SCREEN_NAME}"; \
		echo ""; \
		mkdir -p lib/$${PICKED_MODULE}/Screens/$${SCREEN_NAME}; \
		cp -rv $(TEMPLATES_PATH)/Screen/* lib/$${PICKED_MODULE}/Screens/$${SCREEN_NAME}; \
		find lib/$${PICKED_MODULE}/Screens/$${SCREEN_NAME} -type f -name "*FILE_NAME*" -print0 | while read -d $$'\0' FILE; do \
			mv "$$FILE" "$${FILE//FILE_NAME/$${SCREEN_NAME}}"; \
		done; \
		find lib/$${PICKED_MODULE}/Screens/$${SCREEN_NAME} -type f ! -name '.DS_Store' -exec sed -i '' -e "s/\$${FILE_NAME}/$${SCREEN_NAME}/g" {} \; ; \
		echo "\n$${SCREEN_NAME} screen created in lib/$${PICKED_MODULE}/Screens/$${SCREEN_NAME}"; \
		echo $(SCRIPT-HEADER-SUCCESS) "SCREEN CREATED SUCCESSFUL" $(SCRIPT-FOOTER); \
	fi

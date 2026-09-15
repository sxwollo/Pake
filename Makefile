TUITUI_CONFIG := src-tauri/.pake/tauri.conf.json
TUITUI_PAKE_CONFIG := src-tauri/.pake/pake.json
TUITUI_PROXY_URL := socks5://127.0.0.1:9090
TUITUI_APP := /Applications/推推.app
TUITUI_BIN := pake-tuitui
TUITUI_RELEASE := src-tauri/target/release/bundle/macos/推推.app
TUITUI_DEBUG := src-tauri/target/debug/bundle/macos/推推.app

.PHONY: tuitui tuitui-debug

tuitui:
	npx tauri build --config $(TUITUI_CONFIG) --features cli-build --bundles app
	@pkill -f $(TUITUI_BIN) 2>/dev/null || true
	@sleep 1
	@rm -rf $(TUITUI_APP)
	@cp -R $(TUITUI_RELEASE) $(TUITUI_APP)
	@rm -rf $(TUITUI_RELEASE)
	@open $(TUITUI_APP)
	@echo "✔ 构建完成并已启动: $(TUITUI_APP)"

tuitui-debug:
	@tmp_config=$$(mktemp); \
	cp $(TUITUI_PAKE_CONFIG) $$tmp_config; \
	trap 'cp $$tmp_config $(TUITUI_PAKE_CONFIG); rm -f $$tmp_config' EXIT; \
	node -e "const fs = require('fs'); const configPath = '$(TUITUI_PAKE_CONFIG)'; const config = JSON.parse(fs.readFileSync(configPath, 'utf8')); config.proxy_url = '$(TUITUI_PROXY_URL)'; fs.writeFileSync(configPath, JSON.stringify(config, null, 4) + '\n');"; \
	npx tauri build --debug --config $(TUITUI_CONFIG) --features cli-build,macos-proxy --bundles app
	@pkill -f $(TUITUI_BIN) 2>/dev/null || true
	@sleep 1
	@rm -rf $(TUITUI_APP)
	@cp -R $(TUITUI_DEBUG) $(TUITUI_APP)
	@rm -rf $(TUITUI_DEBUG)
	@open $(TUITUI_APP)
	@echo "✔ 调试版构建完成并已启动: $(TUITUI_APP)"

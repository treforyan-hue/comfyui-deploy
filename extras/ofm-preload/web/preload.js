/*
 * OFM Workflow Preload (frontend extension)
 *
 * Авто-загрузка workflow в ComfyUI при открытии URL вида:
 *   https://<pod>:<port>/?wf=<workflow_id>            (один WF)
 *   https://<pod>:<port>/?wfs=<id1,id2,id3>&active=N  (bundle, активная вкладка N)
 *
 * Принцип:
 *   ComfyUI frontend (v1.42+) при boot читает sessionStorage:
 *     `Comfy.Workflow.ActivePath:<clientId>`  → активный workflow
 *     `Comfy.Workflow.OpenPaths:<clientId>`   → массив открытых вкладок
 *   Затем persistence composable вызывает workflowService.openWorkflow().
 *   Мы pre-seed-им эти ключи ДО того как persistence их прочитает.
 *
 * Условие для работы:
 *   - Файлы <id>.json должны лежать в /workspace/ComfyUI/user/default/workflows/
 *     (бот SSH-аплоадит после ready и после add_wf).
 *   - Setting "Comfy.Workflow.Persist" должен быть включён (default true).
 *   - Frontend version: pinned 1.42.6 (см. comfyui-deploy/Dockerfile).
 *
 * Graceful degradation:
 *   - Нет query params → ничего не делаем (текущее поведение, пустой canvas).
 *   - Файла нет на диске → frontend isValidPath отфильтрует, fallback на пустой.
 *   - Persist отключён → seed игнорируется, workflows доступны в сайдбаре (1 клик).
 */
(function () {
    "use strict";
    try {
        const params = new URLSearchParams(window.location.search);
        const single = params.get("wf");
        const bundle = params.get("wfs");
        if (!single && !bundle) return;  // обычное поведение

        const ids = (bundle || single).split(",")
            .map(function (s) { return s.trim(); })
            .filter(function (s) { return s.length > 0; });
        if (ids.length === 0) return;

        // Активная вкладка из ?active=<idx>, default 0 (первая в bundle).
        let active = parseInt(params.get("active") || "0", 10);
        if (isNaN(active) || active < 0 || active >= ids.length) active = 0;

        const paths = ids.map(function (id) { return "workflows/" + id + ".json"; });
        const workspaceId = "personal";

        // ClientId: должен совпадать с тем что api.ts использует.
        // api.ts читает localStorage, создаёт UUID если пусто. Мы делаем так же —
        // если api.ts успел раньше, читаем его значение (совпадение). Если мы
        // первые — записываем, api.ts потом прочитает то же.
        const CID_KEY = "Comfy.ClientId";
        let clientId = localStorage.getItem(CID_KEY);
        if (!clientId) {
            clientId = (window.crypto && window.crypto.randomUUID)
                ? window.crypto.randomUUID()
                : "ofm-" + Date.now() + "-" + Math.random().toString(36).slice(2);
            localStorage.setItem(CID_KEY, clientId);
        }

        sessionStorage.setItem(
            "Comfy.Workflow.ActivePath:" + clientId,
            JSON.stringify({ workspaceId: workspaceId, path: paths[active] })
        );
        sessionStorage.setItem(
            "Comfy.Workflow.OpenPaths:" + clientId,
            JSON.stringify({ workspaceId: workspaceId, paths: paths, activeIndex: active })
        );

        // Чистим query params чтобы reload не переигрывал то же самое
        // (ComfyUI template-loader так же делает после загрузки темплейта).
        if (window.history && window.history.replaceState) {
            try {
                window.history.replaceState(null, "", window.location.pathname);
            } catch (_) { /* ignore */ }
        }

        console.log("[ofm-preload] seeded sessionStorage:", paths, "active:", active);
    } catch (e) {
        console.warn("[ofm-preload] failed (graceful, falls back to empty canvas):", e);
    }
})();

python3 - <<'PY'
import re, pathlib

base = pathlib.Path("/root/kubernetes/my-website/gitops/clusters/prod/root")

targets = []
targets += list((base / "applications/infra/database").glob("*.yaml"))
targets += list((base / "applications/infra/rook-ceph").glob("*.yaml"))

# projects는 include로 고른 파일만 검사(원하면 여기에 더 추가)
projects = ["apps.yaml","database.yaml","infra.yaml","monitoring.yaml","security.yaml","storage.yaml"]
targets += [base / "projects" / p for p in projects if (base/"projects"/p).exists()

bad = []
for f in sorted(set(targets)):
    txt = f.read_text(errors="ignore")
    docs = re.split(r'(?m)^\s*---\s*$', txt)
    for i, d in enumerate(docs, 1):
        # 주석/공백 제거
        lines = [ln for ln in d.splitlines()
                 if ln.strip() and not ln.lstrip().startswith("#")]
        if not lines:
            bad.append((f, i, "EMPTY_DOCUMENT (just --- or blank)"))
            continue
        has_api = any(re.match(r'^\s*apiVersion\s*:', ln) for ln in lines)
        has_kind = any(re.match(r'^\s*kind\s*:', ln) for ln in lines)
        if not has_api or not has_kind:
            bad.append((f, i, f"MISSING {'apiVersion' if not has_api else ''} {'kind' if not has_kind else ''}".strip()))
if bad:
    print("❌ Problematic YAML docs found:")
    for f,i,reason in bad:
        print(f" - {f} (doc #{i}): {reason}")
else:
    print("✅ No empty/missing apiVersion/kind docs found in targeted files.")
PY


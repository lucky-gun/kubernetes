python3 - <<'PY'
import os, re, fnmatch
from pathlib import Path

ROOT = Path("/root/kubernetes/my-website/gitops")

# 스캔 대상(원하면 추가/삭제)
SCAN_DIRS = [
    ROOT / "clusters",
    ROOT / "infrastructure",
]

# "K8s 매니페스트가 아닌 YAML"을 기본 제외(여기 때문에 전체 스캔이 현실적으로 가능해짐)
EXCLUDE_BASENAMES = {
    "values.yaml", "values.yml",
    "Chart.yaml", "Chart.yml",
    "requirements.yaml", "requirements.yml",
    ".gitignore",
    # 필요하면 더 추가:
    "config.yaml", "config.yml",  # (주의) 인프라에 실제 매니페스트 config가 있으면 제거
}

# 경로 패턴으로 제외(helm chart/templates, git, 등)
EXCLUDE_PATH_PATTERNS = [
    "*/.git/*",
    "*/node_modules/*",
    "*/charts/*",
    "*/templates/*",
]

YAML_EXTS = (".yaml", ".yml")

def is_excluded(path: Path) -> bool:
    if path.name in EXCLUDE_BASENAMES:
        return True
    s = str(path)
    for pat in EXCLUDE_PATH_PATTERNS:
        if fnmatch.fnmatch(s, pat):
            return True
    return False

def split_docs(text: str):
    # 문서 구분자 '---' 기준 split
    return re.split(r'(?m)^\s*---\s*$', text)

def get_key_value(lines, key):
    # key: value 형태에서 value만 뽑기 (빈 값도 감지)
    for ln in lines:
        m = re.match(rf'^\s*{re.escape(key)}\s*:\s*(.*)\s*$', ln)
        if m:
            return m.group(1)
    return None

bad = []
scanned_files = 0
for base in SCAN_DIRS:
    if not base.exists():
        continue
    for root, dirs, files in os.walk(base):
        # 숨김 폴더 빠르게 스킵
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for name in files:
            if not name.endswith(YAML_EXTS):
                continue
            p = Path(root) / name
            if is_excluded(p):
                continue

            scanned_files += 1
            try:
                txt = p.read_text(errors="ignore")
            except Exception as e:
                bad.append((p, 0, f"READ_ERROR: {e}"))
                continue

            docs = split_docs(txt)
            for idx, d in enumerate(docs, 1):
                # 주석/공백 제거한 라인만
                lines = [ln for ln in d.splitlines()
                         if ln.strip() and not ln.lstrip().startswith("#")]

                if not lines:
                    bad.append((p, idx, "EMPTY_DOCUMENT (just '---' or blank)"))
                    continue

                api = get_key_value(lines, "apiVersion")
                kind = get_key_value(lines, "kind")

                # 키 자체가 없으면
                if api is None or kind is None:
                    missing = []
                    if api is None: missing.append("apiVersion")
                    if kind is None: missing.append("kind")
                    bad.append((p, idx, "MISSING " + ",".join(missing)))
                    continue

                # 값이 비어있으면 (이게 groupVersion empty의 핵심 원인)
                api_val = api.strip().strip('"').strip("'")
                kind_val = kind.strip().strip('"').strip("'")
                if api_val == "" or api_val.lower() in {"null", "~"}:
                    bad.append((p, idx, "EMPTY apiVersion VALUE"))
                if kind_val == "" or kind_val.lower() in {"null", "~"}:
                    bad.append((p, idx, "EMPTY kind VALUE"))

# 출력
print(f"Scanned files: {scanned_files}")
if bad:
    print("❌ Problematic YAML docs found:")
    for p, idx, reason in bad:
        print(f" - {p} (doc #{idx}): {reason}")
else:
    print("✅ No empty/missing apiVersion/kind docs found (after exclusions).")
PY


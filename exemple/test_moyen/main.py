import csv
import glob
import os
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

app = FastAPI(title="mindctl test_moyen API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

TMP_DIR = Path("/tmp")
LOG_DIR = Path("/var/log/mindctl/reports")

@app.get("/api/tables")
async def get_tables():
    files = glob.glob(str(TMP_DIR / "mindctl_*_clean.csv"))
    tables = [os.path.basename(f).split('_')[1] for f in files]
    return {"tables": sorted(tables)}

@app.get("/api/csv/{table}")
async def get_csv(table: str):
    file_path = TMP_DIR / f"mindctl_{table}_clean.csv"
    if not file_path.exists():
        raise HTTPException(status_code=404, detail="Fichier non trouvé")
    
    with open(file_path, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        data = list(reader)
        return {
            "table": table,
            "total_lignes": len(data),
            "colonnes": reader.fieldnames,
            "donnees": data
        }

@app.get("/api/stats")
async def get_stats():
    file_path = LOG_DIR / "last_data.txt"
    content = file_path.read_text() if file_path.exists() else "Aucune analyse disponible"
    return {"stats": content}

@app.get("/api/depguard")
async def get_depguard():
    file_path = LOG_DIR / "last_depguard.txt"
    if not file_path.exists():
        return {"conflits": [], "total": 0}
    
    content = file_path.read_text()
    conflits = []
    # Split par blocs séparés par ---
    blocks = content.strip().split("---")
    
    for block in blocks:
        if not block.strip(): continue
        lines = block.strip().split("\n")
        d = {}
        for line in lines:
            if ":" in line:
                key, val = line.split(":", 1)
                d[key.strip().lower()] = val.strip()
        if d:
            conflits.append(d)
            
    return {"conflits": conflits, "total": len(conflits)}

app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
async def read_index():
    return FileResponse('static/index.html')

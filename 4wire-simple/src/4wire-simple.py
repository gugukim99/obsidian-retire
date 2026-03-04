"""
Keithley 2460 SourceMeter - van der Pauw 면저항 측정
4선 (4-wire) 방식, 50 uA 전류 인가, 10회 측정 (1초 간격)
결과 CSV 저장: results/YYYYMMDD_HHMMSS.csv (시작 시간 단일 파일)
"""

import pyvisa
import csv
import time
import os
from datetime import datetime

# ── 설정 ──────────────────────────────────────────────────
SOURCE_CURRENT_A = 50e-6   # 50 uA
MEASURE_COUNT    = 10      # 측정 횟수
MEASURE_INTERVAL = 1.0     # 측정 간격 (초)
RESULTS_DIR      = os.path.join(os.path.dirname(__file__), "..", "results")

# ── 폴더 생성 ─────────────────────────────────────────────
os.makedirs(RESULTS_DIR, exist_ok=True)

# ── VISA 연결 ─────────────────────────────────────────────
rm = pyvisa.ResourceManager()

# 연결된 장비 목록 출력
resources = rm.list_resources()
print("검색된 장비:", resources)

# Keithley 2460 USB 연결 (USB::INSTR 포함 장비 자동 선택)
keithley_addr = None
for r in resources:
    if "USB" in r or "GPIB" in r:
        keithley_addr = r
        break

if keithley_addr is None:
    raise RuntimeError("Keithley 2460을 찾을 수 없습니다. USB 연결을 확인하세요.")

print(f"연결 장비: {keithley_addr}")
smu = rm.open_resource(keithley_addr)
smu.timeout = 10000  # 10초

# ── 장비 초기화 ───────────────────────────────────────────
smu.write("*RST")
time.sleep(1)

idn = smu.query("*IDN?")
print(f"장비 확인: {idn.strip()}")

# ── 소스/측정 설정 ────────────────────────────────────────
smu.write("SOUR:FUNC CURR")                    # 전류 소스 모드
smu.write("SOUR:CURR:RANG:AUTO ON")            # 전류 범위 자동
smu.write(f"SOUR:CURR {SOURCE_CURRENT_A:.2e}") # 50 uA 설정
smu.write("SENS:FUNC 'VOLT'")                  # 전압 측정 모드
smu.write("SENS:VOLT:RANG:AUTO ON")            # 전압 범위 자동
smu.write("SENS:VOLT:RSEN ON")                 # 4선 원격 감지 활성화
smu.write("OUTP ON")                           # 출력 ON

print(f"\n출력 전류: {SOURCE_CURRENT_A*1e6:.0f} uA")
print(f"측정 횟수: {MEASURE_COUNT}회 (간격: {MEASURE_INTERVAL}초)\n")

# ── CSV 파일 준비 (시작 시간으로 파일명) ──────────────────
start_ts = datetime.now()
fname = f"{start_ts.strftime('%Y%m%d_%H%M%S')}.csv"
fpath = os.path.join(RESULTS_DIR, fname)

fieldnames = ["측정번호", "시간", "입력전류(A)", "출력전압(V)", "저항(Ω)", "면저항(Ω/sq)"]

# ── 측정 루프 ─────────────────────────────────────────────
with open(fpath, "w", newline="", encoding="utf-8-sig") as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    for i in range(1, MEASURE_COUNT + 1):
        ts = datetime.now()
        voltage = float(smu.query("READ?"))
        resistance = voltage / SOURCE_CURRENT_A  # R = V / I (Ω)
        sheet_resistance = resistance * (3.14159265 / 0.6931472)  # Rs = R * π/ln2 (van der Pauw 단순화)

        row = {
            "측정번호": i,
            "시간": ts.strftime("%Y-%m-%d %H:%M:%S"),
            "입력전류(A)": f"{SOURCE_CURRENT_A:.6f}",
            "출력전압(V)": f"{voltage:.6f}",
            "저항(Ω)": f"{resistance:.4f}",
            "면저항(Ω/sq)": f"{sheet_resistance:.4f}",
        }
        writer.writerow(row)

        print(f"[{i:02d}] {row['시간']}  I={SOURCE_CURRENT_A:.2e} A  V={voltage:.4e} V  R={resistance:.4f} Ω  Rs={sheet_resistance:.4f} Ω/sq")

        if i < MEASURE_COUNT:
            time.sleep(MEASURE_INTERVAL)

# CSV 파일 닫힘 (with 블록 종료)
print(f"\n저장 완료: {fpath}")

# ── 출력 OFF 및 해제 ──────────────────────────────────────
smu.write("OUTP OFF")
smu.close()
rm.close()

print(f"측정 완료. results/{fname} 에 저장되었습니다.")

# ── 저장된 파일 오픈 (탐색기) ─────────────────────────────
abs_results = os.path.abspath(RESULTS_DIR)
os.startfile(abs_results)

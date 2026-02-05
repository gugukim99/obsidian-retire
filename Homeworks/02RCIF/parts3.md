# 그래핀 성장 모니터링용 라만 분광 시스템 구성

## 1. 구리 vs 그래핀 라만 스펙트럼 비교

| 특성    | 구리 (Cu)         | 그래핀 (Graphene)                                    |
| ----- | --------------- | ------------------------------------------------- |
| 라만 활성 | 없음 (금속은 라만 비활성) | 매우 강함                                             |
| 주요 피크 | 배경 신호만 존재       | **G band (~1580 cm⁻¹)**, **2D band (~2700 cm⁻¹)** |
| 결함 지표 | -               | D band (~1350 cm⁻¹)                               |

**판별 원리:** 구리는 라만 비활성 → G, 2D 피크 출현 시 그래핀 성장 확인

---

## 2. 시스템 구성 부품 추천

### 2.1 레이저 소스 (532nm 권장)

| 모델            | 제조사             | 홈페이지                    | 한국 에이전트               |
| ------------- | --------------- | ----------------------- | --------------------- |
| Gem 532       | Laser Quantum   | www.laserquantum.com    | 레이저옵텍 031-724-6800    |
| MLL-III-532   | CNI Laser       | www.cnilaser.com        | 포토닉스코리아 031-8039-4900 |
| Excelsior 532 | Spectra-Physics | www.spectra-physics.com | MKS코리아 031-336-8161   |

### 2.2 Fiber-coupled Raman Probe

| 모델             | 제조사               | 홈페이지                     | 한국 에이전트             |
| -------------- | ----------------- | ------------------------ | ------------------- |
| RIP-RPB-532-FC | InPhotonics       | www.inphotonics.com      | 해성옵틱스 02-2088-2111  |
| SuperHead      | Horiba            | www.horiba.com           | 호리바코리아 02-6902-2500 |
| RP20           | Wasatch Photonics | www.wasatchphotonics.com | 해성옵틱스 02-2088-2111  |

### 2.3 Detector (분광기 + 검출기)

| 모델 | 제조사 | 홈페이지 | 한국 에이전트 |
|------|--------|----------|---------------|
| WP 532 Raman | Wasatch Photonics | www.wasatchphotonics.com | 해성옵틱스 02-2088-2111 |
| QE Pro-Raman | Ocean Insight | www.oceaninsight.com | 영진프로텍 031-8039-5881 |
| iHR320 | Horiba | www.horiba.com | 호리바코리아 02-6902-2500 |

### 2.4 회로 보드 / 컨트롤러

| 모델 | 제조사 | 홈페이지 | 한국 에이전트 |
|------|--------|----------|---------------|
| NI USB-6001 | National Instruments | www.ni.com | NI코리아 02-3451-3400 |
| Arduino Due | Arduino | www.arduino.cc | 엘레파츠 1544-6498 |

### 2.5 광학 부품

| 부품 | 모델 | 홈페이지 | 한국 에이전트 |
|------|------|----------|---------------|
| Edge Filter | LP03-532RE (Semrock) | www.semrock.com | 해성옵틱스 02-2088-2111 |
| 빔스플리터 | BSW10 (Thorlabs) | www.thorlabs.com | 쏘랩코리아 02-542-0664 |
| 집광렌즈 | AC254-030-A (Thorlabs) | www.thorlabs.com | 쏘랩코리아 02-542-0664 |

### 2.6 소프트웨어 (S/W)

| 소프트웨어 | 제조사 | 홈페이지 | 비고 |
|------------|--------|----------|------|
| ENLIGHTEN | Wasatch Photonics | www.wasatchphotonics.com | 무료 |
| OceanView | Ocean Insight | www.oceaninsight.com | 라이선스 필요 |
| LabVIEW | National Instruments | www.ni.com | NI코리아 02-3451-3400 |

---

## 3. 부품간 호환성 확인

| 구성 | 호환성 |
|------|--------|
| 레이저 → Probe | 532nm 레이저는 RIP-RPB-532-FC와 FC/PC 커넥터로 호환 |
| Probe → Detector | SMA905 커넥터로 Wasatch/Ocean Insight 분광기와 호환 |
| Detector → S/W | Wasatch → ENLIGHTEN, Ocean → OceanView 완벽 호환 |
| 컨트롤러 → 레이저 | NI USB-6001은 TTL 트리거로 대부분 레이저 제어 가능 |

**권장 조합:** CNI MLL-III-532 + InPhotonics Probe + Wasatch WP 532 + ENLIGHTEN

---

## 4. 예상 비용

| 구분 | 예상 비용 (USD) |
|------|-----------------|
| 레이저 | $3,000 - $10,000 |
| Raman Probe | $2,000 - $5,000 |
| 분광기+검출기 | $5,000 - $20,000 |
| 기타 | $1,000 - $3,000 |
| **총합** | **$11,000 - $38,000** |

*주의: 진공 챔버 측정 시 뷰포트 호환성 확인 필요*

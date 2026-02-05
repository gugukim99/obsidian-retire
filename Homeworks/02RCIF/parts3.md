# 그래핀 성장 모니터링용 라만 분광 시스템 구성

## 1. 구리 vs 그래핀 라만 스펙트럼 비교

| 특성 | 구리 (Cu) | 그래핀 (Graphene) |
|------|-----------|-------------------|
| 라만 활성 | 없음 (금속은 라만 비활성) | 매우 강함 |
| 주요 피크 | 배경 신호만 존재 | **G band (~1580 cm⁻¹)**, **2D band (~2700 cm⁻¹)** |
| 결함 지표 | - | D band (~1350 cm⁻¹) |

**판별 원리:** 구리는 라만 비활성 → G, 2D 피크 출현 시 그래핀 성장 확인

---

## 2. 시스템 구성 부품 추천

### 2.1 레이저 소스 (532nm 권장)

| 모델 | 제조사 | 연락처 | 특징 |
|------|--------|--------|------|
| Gem 532 | Laser Quantum | www.laserquantum.com / +44-161-975-5300 | 단일모드, 저잡음 |
| MLL-III-532 | CNI Laser | www.cnilaser.com / +86-431-85603799 | 가성비 우수 |
| Excelsior 532 | Spectra-Physics | www.spectra-physics.com / +1-800-775-5273 | 장기 안정성 |

### 2.2 Fiber-coupled Raman Probe

| 모델 | 제조사 | 연락처 | 특징 |
|------|--------|--------|------|
| RIP-RPB-532-FC | InPhotonics | www.inphotonics.com / +1-781-818-1785 | 532nm 최적화, 필터 내장 |
| SuperHead | Horiba | www.horiba.com / +33-1-69-74-72-00 | 고감도, 다파장 호환 |
| RP20 | Wasatch Photonics | www.wasatchphotonics.com / +1-919-544-7785 | 소형, OEM 적합 |

### 2.3 Detector (분광기 + 검출기)

| 모델 | 제조사 | 연락처 | 특징 |
|------|--------|--------|------|
| WP 532 Raman | Wasatch Photonics | www.wasatchphotonics.com / +1-919-544-7785 | CCD 내장, 턴키 솔루션 |
| QE Pro-Raman | Ocean Insight | www.oceaninsight.com / +1-727-733-2447 | 고감도, USB 연결 |
| iHR320 + Syncerity | Horiba | www.horiba.com / +33-1-69-74-72-00 | 연구급, 고분해능 |

### 2.4 회로 보드 / 컨트롤러

| 모델 | 제조사 | 연락처 | 용도 |
|------|--------|--------|------|
| NI USB-6001 | National Instruments | www.ni.com / +1-888-280-7645 | 레이저 제어, 트리거 |
| Arduino Due | Arduino | www.arduino.cc | 저비용 자동화 |

### 2.5 광학 부품

| 부품 | 모델 | 제조사/연락처 |
|------|------|---------------|
| Edge Filter (532nm) | LP03-532RE | Semrock / www.semrock.com / +1-585-594-7001 |
| 빔스플리터 | BSW10 | Thorlabs / www.thorlabs.com / +1-973-300-3000 |
| 집광렌즈 | AC254-030-A | Thorlabs / www.thorlabs.com / +1-973-300-3000 |

### 2.6 소프트웨어 (S/W)

| 소프트웨어 | 제조사 | 연락처 | 용도 |
|------------|--------|--------|------|
| ENLIGHTEN | Wasatch Photonics | www.wasatchphotonics.com | 무료, 스펙트럼 수집 |
| OceanView | Ocean Insight | www.oceaninsight.com | 데이터 분석 |
| LabVIEW | National Instruments | www.ni.com | 커스텀 자동화 |

---

## 3. 부품간 호환성 확인

| 구성 | 호환성 |
|------|--------|
| **레이저 → Probe** | 532nm 레이저는 RIP-RPB-532-FC와 직접 호환 (FC/PC 커넥터) |
| **Probe → Detector** | InPhotonics Probe는 Wasatch/Ocean Insight 분광기와 SMA905 커넥터로 호환 |
| **Detector → S/W** | Wasatch → ENLIGHTEN, Ocean Insight → OceanView 자사 S/W 완벽 호환 |
| **컨트롤러 → 레이저** | NI USB-6001은 TTL 트리거로 대부분 레이저 제어 가능 |
| **광학 필터** | Semrock LP03-532RE는 532nm 레이저 전용, 호환성 우수 |

**권장 조합:** CNI MLL-III-532 + InPhotonics RIP-RPB-532-FC + Wasatch WP 532 + ENLIGHTEN

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

# BlueMap Coastal AutoMapper

**A scientific desktop application for shallow-water benthic habitat mapping from multispectral remote sensing imagery.**

Version 2.0.0 | Windows x64 | Signed installer

---

## What this application is

BlueMap Coastal AutoMapper is an offline-first desktop GIS that implements a
complete, reproducible workflow for mapping coral reef, seagrass, and other
shallow-water benthic habitats from optical satellite imagery (for example
Sentinel-2 and Landsat). It packages the standard scientific processing chain
into a single guided interface so that a non-programmer analyst can move from a
raw multispectral image to a validated habitat map with documented provenance.

The application operationalises the Indonesian national technical guideline
**"Panduan Teknis Survei dan Pemetaan Habitat Perairan Laut Dangkal
Menggunakan Citra Penginderaan Jauh dan Klasifikasi Machine Learning"**
(Blue Carbon Research Group, Universitas Gadjah Mada and PT. Mitra Geotama
Indonesia, 2023) from preprocessing through multi-temporal analysis. Every HTML
report produced by the application cites this guideline plus the underlying
peer-reviewed method papers.

This repository distributes the **compiled, code-signed installer only**. The
source code lives in a separate repository.

---

## Scientific workflow and modules

The application is organised around the published mapping workflow. Each stage
maps to a chapter of the technical guideline.

### 1. Image preprocessing
- **Sunglint correction (Hedley module).** Removes specular reflection from the
  water surface using the near-infrared regression method of Hedley, Harborne
  and Mumby (2005). Guideline Bab I.2.
- **Water column correction (Lyzenga module).** Computes depth-invariant
  indices (DII) from band pairs following Lyzenga (1978, 1981), producing a
  three-band depth-invariant stack from blue, green, and red bands. Guideline
  Bab I.3.

### 2. Supervised modeling
- **Classification.** Random Forest (Breiman 2001) and Support Vector Machine
  (Cortes and Vapnik 1995), with single-image and batch modes. Guideline
  Bab III.2.
- **Regression.** Random Forest regression and Support Vector Regression for
  continuous targets such as percent cover or depth proxies.
- **Predictor band selection.** The analyst can choose exactly which raster
  bands feed the model as predictors, with full traceability of the choice in
  the report.
- **Assembly model.** Train a reusable model bundle once and apply it to other
  images. The bundle records the exact predictor bands so inference always uses
  the same spectral inputs.

### 3. Accuracy assessment
- Confusion matrix, overall accuracy, producer and user accuracy, and Cohen
  kappa following Congalton (1991), with bootstrap confidence intervals.
  Guideline Bab III.3.

### 4. Multi-temporal analysis
- Class-area tables, mean and coefficient-of-variation maps, change detection,
  and seasonal-trend decomposition (STL, Cleveland et al. 1990). Guideline
  Bab IV.

Every processing run writes a self-contained HTML report with a standardised
structure: configuration, metrics, diagnostic figures, a provenance and
reproducibility section (predictor bands, random seed, scikit-learn version,
input identifiers), and the citations described above.

---

## Key properties for scientific use

- **Reproducibility.** Random seeds are propagated and recorded. Reports list
  the exact inputs and software versions used for each run.
- **Provenance.** Output GeoTIFFs carry processing tags. Model bundles record
  their predictor band selection.
- **Offline-first.** No network connection is required for any analysis step.
- **No silent data reduction.** Models train on the full set of labelled
  pixels. The application never discards training data without explicit user
  action.
- **Documented citations.** Each report names the methods and guideline to cite
  in published work.

---

## Installation

See **GUIDE.md** for the full step-by-step guide. In brief:

1. Download `BlueMap-Setup-2.0.0.exe`.
2. Double-click to install. The installer is digitally signed. If Windows
   SmartScreen shows an "unknown publisher" notice, choose "More info" then
   "Run anyway", or trust the bundled publisher certificate first (see
   GUIDE.md).
3. Launch BlueMap from the Start menu.

The first launch can take 30 to 60 seconds while Windows scans the bundled
analysis backend. Subsequent launches are faster.

---

## Files in this repository

| File | Purpose |
|---|---|
| `BlueMap-Setup-2.0.0.exe` | The signed Windows installer (Git LFS). |
| `BlueMap-Setup-2.0.0.exe.blockmap` | Differential map used by the auto-updater. |
| `BlueMap-CodeSigning.cer` | Public certificate of the publisher. Safe to share. |
| `trust-cert.ps1` | Helper that trusts the publisher certificate on a machine. |
| `latest.yml` | Auto-update metadata. |
| `version.json` | Human-readable version metadata and changelog. |
| `README.md` | This file. |
| `GUIDE.md` | Brief guide book and workflow walkthrough. |

---

## How to cite

If you use BlueMap Coastal AutoMapper in published work, cite the software and
the technical guideline it implements:

> Harahap, S. D., Firdausman, F., Wijaya, J., Wicaksono, P., and Ardiyanto, R.
> (2023). Panduan Teknis Survei dan Pemetaan Habitat Perairan Laut Dangkal
> Menggunakan Citra Penginderaan Jauh dan Klasifikasi Machine Learning
> (Edisi 1). Blue Carbon Research Group, Fakultas Geografi, Universitas Gadjah
> Mada and PT. Mitra Geotama Indonesia, Yogyakarta.

Also cite the relevant method papers shown in each report (Hedley et al. 2005;
Lyzenga 1978, 1981; Breiman 2001; Cortes and Vapnik 1995; Congalton 1991;
Cleveland et al. 1990).

---

## License

The compiled application is distributed under the MIT License.

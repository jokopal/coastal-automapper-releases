# BlueMap Coastal AutoMapper: Brief Guide Book

This guide walks through installing the application and running a complete
shallow-water habitat mapping workflow. It mirrors the structure of the
technical guideline the application implements.

---

## Part 1: Installation

### Step 1. Download

Download `BlueMap-Setup-2.0.0.exe` from this repository. The file is stored
with Git LFS, so use the "Download" button on the file page rather than copying
the pointer text.

### Step 2. Run the installer

Double-click the installer and follow the wizard:

1. Welcome screen.
2. License agreement.
3. Choose the install folder.
4. Install.

The installer is digitally signed with a self-signed certificate. Windows
SmartScreen may show "Windows protected your PC" because the publisher is not
yet a commercial certificate authority. This does not mean the software is
unsafe.

### Step 3. (Optional) Trust the publisher

To remove the SmartScreen notice for current and future versions:

**Option A, no admin rights:**
1. Install the application first.
2. Open PowerShell and run:
   ```
   cd "$env:LOCALAPPDATA\Programs\BlueMap\resources\app\certificates"
   powershell -ExecutionPolicy Bypass -File .\trust-cert.ps1
   ```
3. Confirm with "Y".

**Option B, machine-wide, requires admin:**
1. Double-click `BlueMap-CodeSigning.cer`.
2. Click "Install Certificate", choose "Local Machine", and place it in both
   "Trusted Publishers" and "Trusted Root Certification Authorities".

### Step 4. First launch

Launch BlueMap from the Start menu. The first start can take 30 to 60 seconds
while Windows scans the bundled analysis backend. If a "Backend not ready"
notice appears, close and relaunch; the second start is normally under ten
seconds. If it persists, add the install folder to your antivirus exclusions.

---

## Part 2: Mapping workflow

The left panel lists processing modules in scientific order. The map is in the
center. The right panel shows results and downloadable HTML reports.

### Stage 1: Load imagery

Use the Data Hub to import a multispectral GeoTIFF (for example a Sentinel-2 or
Landsat surface reflectance image). A bundled sample dataset is available to try
the workflow immediately.

### Stage 2: Preprocessing

1. **Sunglint correction (Hedley).** Run this when the image shows specular
   glint over water. It uses the near-infrared band to estimate and remove
   glint. Skip it for calm, glint-free scenes.
2. **Water column correction (Lyzenga).** Produces a three-band
   depth-invariant index stack from the blue, green, and red bands. This
   reduces the effect of variable water depth on bottom reflectance, which
   improves habitat separability.

### Stage 3: Training data

Prepare a training vector (polygons or points) labelled with habitat classes.
The application integrates field-survey labels with the image grid as described
in the guideline.

### Stage 4: Classification or regression

1. Choose the input raster and training vector.
2. Open "Predictor bands (advanced)" to pick which bands feed the model. The
   default uses every band.
3. Choose the algorithm:
   - **Random Forest** is parallel and fast and is the recommended default.
   - **Support Vector Machine** can be more accurate on some scenes but trains
     much more slowly on large training sets, since its cost grows with the
     square of the number of training pixels.
4. Run single-image or batch mode.
5. The output map registers into the Data Hub with full edit and delete
   controls, and a result card appears in the right panel.

### Stage 5: Accuracy assessment

Supply a separate validation vector. The application computes the confusion
matrix, overall accuracy, producer and user accuracy, Cohen kappa, and bootstrap
confidence intervals. Results appear in the report.

### Stage 6: Multi-temporal analysis

With several classified maps from different dates you can produce class-area
tables, mean and coefficient-of-variation maps, change-detection maps, and
seasonal-trend decompositions to study habitat dynamics over time.

---

## Part 3: Reports and reproducibility

Every run produces a self-contained HTML report. Open it with the "Report"
button on the result card. Each report contains:

- **Configuration:** algorithm and parameters used.
- **Metrics:** accuracy or regression metrics with confidence intervals.
- **Diagnostic figures:** confusion matrix, scatter plots, and similar.
- **Provenance and reproducibility:** predictor bands, random seed,
  scikit-learn version, and input identifiers.
- **Citations:** the technical guideline chapter and the method papers to cite.

To reproduce a run, use the same inputs, the same predictor bands, and the same
random seed on the same software version.

---

## Part 4: Housekeeping

- **Output retention.** Result files older than seven days are cleaned up
  automatically. Registered layers are preserved until you delete them.
- **Uninstall.** Use Settings, Apps, then BlueMap Coastal AutoMapper. User data
  under `%APPDATA%\bluemap-electron\` is kept by default; delete it manually for
  a full removal.

---

## Support and citation

Report issues with the contents of
`%APPDATA%\bluemap-electron\logs\last-startup-failure.json` when relevant.

When you publish results, cite the software and the technical guideline (see
README.md, section "How to cite").

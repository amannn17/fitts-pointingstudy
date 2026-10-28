# Mouse vs. Phone Tilt: A Fitts' Law Pointing Study

Phone-tilt pointing reached about **40% of mouse throughput** (1.6 vs. 4.3 bits/s, effective throughput) in a controlled reciprocal tapping experiment, and **all 9 participants who used both devices were faster with the mouse**. The phone's cost grew sharply with difficulty, especially for small targets.

This repository contains the experiment (in Processing and in the browser), the data, and the analysis in Python.

![Fitts' law lines for mouse and phone tilt](analysis/fitts_lines.png)

---

## Motivation and research question

I had previously built a creative project that used a phone's tilt sensor (via ZigSim) to control visuals in Processing. Here I turned that idea into an input technique and evaluated it the way HCI research evaluates pointing: with a controlled experiment and Fitts' law.

**Research question:** how does phone-tilt pointing compare to a mouse in speed, accuracy and throughput?

The mouse is the **baseline**. A phone throughput number means little on its own; next to the mouse it becomes a finding. The mouse data also checks the setup: if it follows Fitts' law closely and lands in the usual throughput range, the task measures pointing correctly.

## Method

**Task.** A reciprocal tapping task (as in Fitts, 1954). Two circular targets sit side by side; the highlighted one must be selected, then the other, back and forth. Each hit ends one trial; movement time (MT) is the time since the previous hit. Selections outside the target are recorded as errors, and the timer keeps running through them. Participants were asked to work "as quickly and accurately as you can".

**Conditions.** On a 1200 × 600 logical canvas:

| | Values |
|---|---|
| Distance A (centre to centre) | 250, 500, 900 px |
| Target width W (diameter) | 20, 40, 80 px |
| Combinations | 9, index of difficulty ID = log₂(A/W + 1) from 2.04 to 5.52 bits |
| Hits per combination | 10 (after one unrecorded start click) |
| Rounds per device | 1, in random order |
| Practice | 2 short sets of 3 hits, not recorded |

**Devices.**
- **Mouse** (or trackpad: participants used their own computer and reported which).
- **Phone tilt:** the phone is a controller; the targets stay on the computer screen. Tilting the phone moves a cursor (position control), and tapping anywhere on the phone's screen selects.

**Design.** Within-subjects: each participant used both devices. Device order was meant to be counterbalanced by participant code; in practice 7 started with the mouse and 2 with the phone. No hover feedback was shown on either device, and the mouse was ignored in phone mode, so both devices got the same visual information.

**Participants.** 11 people, identified only by random codes. 9 completed both devices; 2 completed the mouse part only. Of the 9 complete pairs, 4 used a mouse and 5 a trackpad. Sessions were run remotely in the browser on 26 October 2026, after a pilot on myself.

## Implementation

**Processing version** (`experiment/`). Built around four small classes:

| Class | Responsibility |
|---|---|
| `Target` | Position and diameter; draws itself; `contains(x, y)` tests whether a point is inside |
| `Trial` | One selection's data; computes its own ID |
| `Condition` | One A/W combination |
| `Study` | Builds and shuffles the 9 conditions and steps through them |

Both devices write into one shared pointer, and all selection logic lives in one function, so the experiment is identical for both; only the input differs. The phone sends gravity and touch data over OSC (ZigSim, oscP5).

**Browser version** ([try it live](https://amannn17.github.io/pointing-study_remote/) · [source]((https://github.com/amannn17/pointing-study_remote))). A port of the Processing version to one HTML file, hosted with GitHub Pages, so other people could take part with their own computer and phone:
- The computer shows a QR code; the phone opens it and connects directly to the computer (WebRTC via PeerJS).
- The phone reports its tilt (DeviceOrientation, in degrees) and taps; the computer does all the calculation.
- Each person's data is sent to a Google Sheet (Apps Script) and only reported as saved once the sheet confirms it, with a download as backup.

**Phone input details.**
- **Mapping:** ±30° of left/right tilt and ±17.5° of forward/back tilt cover the canvas; tilting the top edge toward you moves the cursor up.
- **Calibration:** the participant's comfortable holding angle becomes the centre.
- **Smoothing:** each frame, the cursor moves 25% of the way to the raw tilt position (frame-rate independent), which cuts sensor jitter at the cost of a small lag.
- **Selection:** one selection per tap (edge detection), so holding a finger down doesn't select repeatedly.

## Analysis

The analysis is in two Jupyter notebooks in `analysis/`.

**Cleaning** (`clean.ipynb`). All rules were fixed before comparing the devices.

| Step | Rows |
|---|---|
| Raw data | 2,456 selections |
| Remove 29 double taps (a miss < 250 ms after a hit, landing on the just-hit target; all on the phone) | 2,427 selections (used for error rate) |
| Hits only | 1,800 |
| Drop the first movement of each condition (a "getting going" delay) | 1,620 |
| Remove outliers: MT > 3 × the median for that person, device and condition (1%) | 1,604 hits (used for timing) |

I used a median-based outlier rule because a 3-standard-deviation rule cannot work with about ten values per condition: an extreme value inflates the standard deviation meant to catch it.

**Measures** (`analyse.ipynb`).
- **Fitts' law fit:** mean MT per person and condition, averaged across people, then MT = a + b × ID per device.
- **Throughput:** ID / MT per condition, averaged per person and device.
- **Effective throughput:** the effective width We = 4.133 × SD of selection positions along the movement axis, so a fast but inaccurate participant is scored as having used a larger target. This folds speed and accuracy into one number. Selections that landed nearer the other target (14) were left out of this spread.
- **Paired t-test** on each person's mouse vs. phone score (exploratory, given the sample size).
- **Error rate:** misses / all selections, per device and per target width.

## Results

| | Mouse | Phone tilt |
|---|---|---|
| Fitts' law fit | MT = 184 + 186 × ID | MT = −814 + 885 × ID |
| R² | 0.95 | 0.93 |
| Throughput (TP) | 4.50 bits/s | 1.89 bits/s |
| Effective throughput (TPe) | 4.57 bits/s | 1.61 bits/s |
| Error rate | 9.8% | 32.1% |
| Errors at W = 20 / 40 / 80 px | 15% / 8% / 4% | 41% / 26% / 21% |

Throughput values are means over all participants who used each device (11 mouse, 9 phone).

**Every participant was faster with the mouse.** For the 9 people who used both devices, effective throughput was 4.30 vs. 1.61 bits/s (mean difference 2.69 bits/s, paired t(8) = 10.73, p < .001).

![Throughput per participant on both devices](analysis/throughput_pairs.png)

**The phone's cost grows with difficulty.** Each extra bit of difficulty cost about 186 ms with the mouse and 885 ms with the phone. The phone was about 2× slower on the easiest condition and 3× slower on the hardest.

**Small targets hurt the phone most.** Even the largest phone targets were missed more often (21%) than the smallest mouse targets (15%).

![Error rate by target width](analysis/errors_by_width.png)

**Robustness checks.** The result held when restricted to real-mouse users (n = 4, difference 2.81 bits/s) and without the least accurate participant (n = 8, difference 2.64 bits/s); every person in each subset was faster with the mouse.

## Discussion

**The setup measures pointing correctly.** The mouse follows Fitts' law closely (R² = 0.95) and its throughput (about 4.5 bits/s) sits in the range usually reported for mice, even though participants used their own computers remotely.

**Phone tilt is a much less efficient pointing technique**, at roughly 40% of mouse throughput. The gap is not constant: it widens as targets get smaller and further away.

**Small targets cost the phone more than Fitts' law predicts.** Two phone conditions with almost the same ID took very different times: A = 900, W = 80 (ID 3.61) took 2,067 ms, while A = 250, W = 20 (ID 3.75) took 2,844 ms. The mouse shows no such jump. This fits the sensor's sensitivity: with position control, a tiny wobble moves the cursor several pixels, so staying on a 20 px target long enough to tap is hard. The effective widths show the same thing: on 20 px targets, phone users were effectively hitting a 56 px target. This also explains the phone's negative intercept, which is not meaningful in itself; it comes from extending a steep line below the tested range.

**Effective throughput widened the gap** (from 2.4 to 2.7 bits/s), because plain throughput gave the phone credit for speed without charging for its many misses.

**No clear evidence of a "Heisenberg effect"**, where tapping the phone would nudge the cursor at the moment of selection. Phone selections showed no consistent vertical shift beyond the one the mouse also showed (2.3 vs. 0.9 px). They were, however, about three times more scattered.

### Limitations

- **Small sample:** 9 complete pairs. The direction of the result is very consistent, but the exact sizes are uncertain.
- **Unbalanced device order:** 7 people started with the mouse and 2 with the phone, so learning or fatigue effects may not cancel out.
- **Uncontrolled setups:** remote sessions on participants' own screens (different physical sizes), mice and trackpads, phones and Wi-Fi.
- **Phone input design choices:** the tilt range, smoothing (which adds a small lag) and calibration all affect performance; other choices could do better.
- **Network:** phone taps travel over the network, adding a few milliseconds.
- **Heisenberg check is indirect:** only the cursor position at the moment of selection was logged.

### What I'd do next

- **Measuring the effort, not just the speed, and adding the head as a third pointer.** Participants found phone tilt more tiring, but this study only measured speed and accuracy. Building on my earlier brain-wave visualisation project, a follow-up could use an Emotiv EPOC X headset for two things at once. Its built-in motion sensor can drive a **head-tilt pointer**, using the same tilt-to-cursor mapping as the phone, giving three techniques to compare: mouse, phone tilt and head tilt. Its 14 EEG channels, which cover frontal and parietal areas linked to mental workload, can record **how demanding each technique is** during the same Fitts' task, alongside a workload questionnaire (NASA-TLX). The question: is phone tilt also more mentally demanding, especially on small targets, and does freeing the hands (head tilt) change that? Movement adds noise to EEG, so the EEG part would be exploratory, with the questionnaire as the reference measure.
- **Gaze + tilt: does Fitts' law survive when the eyes do the travelling?** Gaze is fast and nearly distance-independent but imprecise; phone tilt struggled most with distant, small targets. A hybrid, where gaze moves the cursor near the target and tilt does the final adjustment (with a phone tap to select, avoiding gaze's "Midas touch" problem), could remove the distance cost. Would movement time then still depend on the ratio A/W, as Fitts' law predicts and as my data showed (A = 250, W = 40 and A = 500, W = 80 took the same time), or only on target width? This builds on gaze-supported techniques such as Look & Touch (Stellmach & Dachselt, CHI 2012).
- **Smaller improvements to this study:** try a gyroscope-based "air mouse" mapping on the same phone (rotation speed moves the cursor), to separate the technique from the device; log the cursor position about 100 ms before each tap, to measure the Heisenberg effect directly; make the page enforce the device order; and run more participants, some in person on the same equipment.

## How to run it

**Browser version.** Open the study page (GitHub Pages link: *add here*) on a computer, and follow the steps. For the phone part, scan the QR code with a phone on the same Wi-Fi. Data saving needs a Google Apps Script web app (`doPost` writes rows to a Sheet), deployed as *Execute as: Me, Who has access: Anyone*; put its `/exec` address in `CONFIG.endpoint` in `index.html`.

**Processing version.**
1. Install the **oscP5** library.
2. In ZigSim, enable **Gravity** and **Touch**, set the port to **9000** and the message rate to 60 per second; phone and computer on the same Wi-Fi.
3. Open `experiment/experiment.pde` and run it. Type a participant code, press **TAB** to choose the device, **Enter** to start (this also calibrates the phone). During the task: **C** re-centres the phone, **S** saves a backup. Data is saved automatically to `data/`.

**Analysis.** With Python, pandas, NumPy, SciPy and matplotlib installed, run `analysis/clean.ipynb`, then `analysis/analyse.ipynb`.

## Repository structure

```
experiment/     Processing sketch (main tab + Target, Trial, Condition, Study)
zigsim_test/    Tool used to record tilt values
analysis/       Cleaning and analysis notebooks, plots
data/           Raw export and cleaned data (participant codes only)
```

## How this was built

I designed the study, wrote the Processing version, ran the pilot and the main study, and made all analysis decisions before comparing the devices. I used an AI assistant (Claude) as a tutor throughout: for explanations, code review and help with debugging. The browser version, used to run participants remotely, was generated with Claude from my Processing version and specifications; I tested and deployed it.

## Privacy

Participants gave consent on the study's first page and are identified only by random codes; no names are stored.
